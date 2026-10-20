import CoreLocation
import Darwin
import Foundation
import Network
import NetworkExtension
import WifiSpectrumCore

/// Resumes a continuation exactly once even when several callbacks race (ready, failure, timeout).
final class OnceBox<T>: @unchecked Sendable {
    private var continuation: CheckedContinuation<T, Never>?
    private let lock = NSLock()

    init(_ c: CheckedContinuation<T, Never>) { continuation = c }

    func resume(_ value: T) {
        lock.lock()
        let c = continuation
        continuation = nil
        lock.unlock()
        c?.resume(returning: value)
    }
}

// MARK: - Wi-Fi information

final class SystemWifiInfo: NSObject, WifiInfoProviding, CLLocationManagerDelegate {
    private let location = CLLocationManager()
    private var authWaiters: [CheckedContinuation<Void, Never>] = []

    override init() {
        super.init()
        location.delegate = self
    }

    @MainActor
    func requestAccess() async {
        guard location.authorizationStatus == .notDetermined else { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            authWaiters.append(c)
            location.requestWhenInUseAuthorization()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        let waiters = authWaiters
        authWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    func current() async -> WifiAccess {
        switch location.authorizationStatus {
        case .notDetermined: return .needsLocationPermission
        case .denied, .restricted: return .locationDenied
        default: break
        }
        let network: NEHotspotNetwork? = await withCheckedContinuation { c in
            NEHotspotNetwork.fetchCurrent { c.resume(returning: $0) }
        }
        guard let n = network else { return .notConnected }
        var security: Int?
        if #available(iOS 15.0, *) { security = n.securityType.rawValue }
        return .available(WifiSnapshot(ssid: n.ssid, bssid: MacAddress.padded(n.bssid), securityRaw: security))
    }

    func interface() async -> InterfaceSnapshot {
        let path: Network.NWPath = await withCheckedContinuation { c in
            let monitor = NWPathMonitor()
            let box = OnceBox(c)
            monitor.pathUpdateHandler = { p in
                box.resume(p)
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "path"))
        }
        let addresses = Self.addresses(interface: "en0")
        return InterfaceSnapshot(
            ipv4: addresses.ipv4, netmask: addresses.netmask, ipv6: addresses.ipv6,
            isWifi: path.usesInterfaceType(.wifi), isExpensive: path.isExpensive, isConstrained: path.isConstrained,
            supportsIPv6: path.supportsIPv6, hasDNS: path.supportsDNS
        )
    }

    static func addresses(interface name: String) -> (ipv4: String?, netmask: String?, ipv6: [String]) {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return (nil, nil, []) }
        defer { freeifaddrs(head) }
        var ipv4: String?
        var mask: String?
        var ipv6: [String] = []
        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let p = cursor {
            defer { cursor = p.pointee.ifa_next }
            guard String(cString: p.pointee.ifa_name) == name, let sa = p.pointee.ifa_addr else { continue }
            let family = Int32(sa.pointee.sa_family)
            if family == AF_INET {
                ipv4 = numericHost(sa)
                if let m = p.pointee.ifa_netmask { mask = numericHost(m) }
            } else if family == AF_INET6, let a = numericHost(sa) {
                ipv6.append(a)
            }
        }
        return (ipv4, mask, ipv6)
    }

    private static func numericHost(_ sa: UnsafeMutablePointer<sockaddr>) -> String? {
        var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let len = socklen_t(sa.pointee.sa_family == UInt8(AF_INET6) ? MemoryLayout<sockaddr_in6>.size : MemoryLayout<sockaddr_in>.size)
        guard getnameinfo(sa, len, &buffer, socklen_t(buffer.count), nil, 0, NI_NUMERICHOST) == 0 else { return nil }
        return String(cString: buffer)
    }
}

// MARK: - TCP latency

struct TCPLatencyProbe: LatencyProbing {
    func connectTime(host: String, port: UInt16, timeout: TimeInterval) async -> Double? {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else { return nil }
        let queue = DispatchQueue(label: "probe.\(host).\(port)")
        return await withCheckedContinuation { c in
            let box = OnceBox<Double?>(c)
            let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
            let start = Date()
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    box.resume(Date().timeIntervalSince(start) * 1000)
                    connection.cancel()
                case .failed, .cancelled:
                    box.resume(nil)
                case .waiting:
                    box.resume(nil)
                    connection.cancel()
                default:
                    break
                }
            }
            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) {
                box.resume(nil)
                connection.cancel()
            }
        }
    }
}

// MARK: - LAN discovery

/// Every NWBrowser handler runs on one serial queue, so the set is never touched concurrently.
private final class FoundServices: @unchecked Sendable {
    var items = Set<BonjourService>()
}

struct SystemLANScanner: LANScanning {
    let probe = TCPLatencyProbe()

    func browse(types: [String], for seconds: TimeInterval) async -> [BonjourService] {
        await withCheckedContinuation { c in
            let box = OnceBox<[BonjourService]>(c)
            let queue = DispatchQueue(label: "bonjour")
            let found = FoundServices()
            let browsers = types.map { type -> NWBrowser in
                let browser = NWBrowser(for: .bonjour(type: type, domain: nil), using: .tcp)
                browser.browseResultsChangedHandler = { results, _ in
                    for r in results {
                        if case let .service(name, t, _, _) = r.endpoint { found.items.insert(BonjourService(name: name, type: t)) }
                    }
                }
                browser.start(queue: queue)
                return browser
            }
            queue.asyncAfter(deadline: .now() + seconds) {
                browsers.forEach { $0.cancel() }
                box.resume(found.items.sorted { ($0.name, $0.type) < ($1.name, $1.type) })
            }
        }
    }

    func sweep(targets: [IPv4], ports: [UInt16], timeout: TimeInterval, progress: @escaping @MainActor (Int) -> Void) async -> [LANHost] {
        var hosts: [LANHost] = []
        var done = 0
        let batch = 16
        var index = 0
        while index < targets.count, !Task.isCancelled {
            let slice = Array(targets[index..<min(index + batch, targets.count)])
            index += slice.count
            let found = await withTaskGroup(of: LANHost?.self) { group -> [LANHost] in
                for ip in slice {
                    group.addTask {
                        var open: [UInt16] = []
                        for port in ports where !Task.isCancelled {
                            if await probe.connectTime(host: ip.description, port: port, timeout: timeout) != nil { open.append(port) }
                        }
                        return open.isEmpty ? nil : LANHost(address: ip, openPorts: open)
                    }
                }
                var out: [LANHost] = []
                for await h in group { if let h { out.append(h) } }
                return out
            }
            hosts += found
            done += slice.count
            await progress(done)
        }
        return hosts.sorted { $0.address < $1.address }
    }
}

// MARK: - DNS

struct SystemDNSResolver: DNSResolving {
    func resolve(_ host: String) async throws -> DNSAnswer {
        guard HostInput.isValid(host) else { throw DNSError.invalidName }
        return try await Task.detached(priority: .userInitiated) {
            var hints = addrinfo()
            hints.ai_family = AF_UNSPEC
            hints.ai_socktype = SOCK_STREAM
            hints.ai_flags = AI_CANONNAME
            var result: UnsafeMutablePointer<addrinfo>?
            let start = Date()
            let status = getaddrinfo(host, nil, &hints, &result)
            let ms = Date().timeIntervalSince(start) * 1000
            guard status == 0, let first = result else { throw DNSError.notFound(String(cString: gai_strerror(status))) }
            defer { freeaddrinfo(result) }
            var v4 = Set<String>()
            var v6 = Set<String>()
            var canonical: String?
            var cursor: UnsafeMutablePointer<addrinfo>? = first
            while let p = cursor {
                if canonical == nil, let c = p.pointee.ai_canonname { canonical = String(cString: c) }
                if let sa = p.pointee.ai_addr {
                    var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(sa, p.pointee.ai_addrlen, &buffer, socklen_t(buffer.count), nil, 0, NI_NUMERICHOST) == 0 {
                        let text = String(cString: buffer)
                        if p.pointee.ai_family == AF_INET { v4.insert(text) } else { v6.insert(text) }
                    }
                }
                cursor = p.pointee.ai_next
            }
            return DNSAnswer(canonicalName: canonical == host ? nil : canonical, ipv4: v4.sorted(), ipv6: v6.sorted(), milliseconds: ms)
        }.value
    }
}

// MARK: - Speed test

/// Measures against Cloudflare's public speed-test endpoints (speed.cloudflare.com).
struct CloudflareSpeedTest: SpeedTesting {
    var downloadBytes = 25_000_000
    var uploadBytes = 8_000_000
    var rounds = 3

    private var session: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }

    func run(progress: @escaping @MainActor (SpeedProgress) -> Void) async throws -> SpeedResult {
        let s = session
        defer { s.finishTasksAndInvalidate() }
        await progress(SpeedProgress(phase: .latency))
        var pings: [Double?] = []
        _ = try? await s.data(from: url("__down?bytes=0"))
        for _ in 0..<10 {
            try Task.checkCancellation()
            let start = Date()
            let ok = (try? await s.data(from: url("__down?bytes=0"))) != nil
            pings.append(ok ? Date().timeIntervalSince(start) * 1000 : nil)
        }
        var down: [Double] = []
        for _ in 0..<rounds {
            try Task.checkCancellation()
            let start = Date()
            let (data, _) = try await s.data(from: url("__down?bytes=\(downloadBytes)"))
            down.append(Throughput.mbps(bytes: data.count, seconds: Date().timeIntervalSince(start)))
            await progress(SpeedProgress(phase: .download, currentMbps: Throughput.estimate(down)))
        }
        var up: [Double] = []
        let body = Data(count: uploadBytes)
        for _ in 0..<rounds {
            try Task.checkCancellation()
            var request = URLRequest(url: url("__up"))
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            let start = Date()
            _ = try await s.upload(for: request, from: body)
            up.append(Throughput.mbps(bytes: body.count, seconds: Date().timeIntervalSince(start)))
            await progress(SpeedProgress(phase: .upload, currentMbps: Throughput.estimate(up)))
        }
        return SpeedResult(downloadMbps: Throughput.estimate(down), uploadMbps: Throughput.estimate(up),
                           latency: LatencyStats(samples: pings), server: "speed.cloudflare.com", date: Date())
    }

    private func url(_ path: String) -> URL { URL(string: "https://speed.cloudflare.com/" + path)! }
}
