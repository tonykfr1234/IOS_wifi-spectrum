import Foundation
import WifiSpectrumCore

/// Synthetic Taipei apartment, matching the Android demo: a Wi-Fi 7 router and a few home devices.
/// Used for the simulator, screenshots, UI tests and anyone exploring without a network.
enum DemoData {
    static let wifi = WifiSnapshot(ssid: "Home-BE", bssid: "04:d9:f5:6e:20:02", securityRaw: 2)
    static let interface = InterfaceSnapshot(
        ipv4: "192.168.50.123", netmask: "255.255.255.0", ipv6: ["fe80::1c2a:5bff:fe3d:9a10", "2001:db8:50::7b"],
        isWifi: true, isExpensive: false, isConstrained: false, supportsIPv6: true, hasDNS: true
    )
    static let hosts: [LANHost] = [
        LANHost(address: IPv4Address("192.168.50.1")!, openPorts: [80, 443]),
        LANHost(address: IPv4Address("192.168.50.10")!, openPorts: [80, 443, 22, 445]),
        LANHost(address: IPv4Address("192.168.50.23")!, openPorts: [22]),
        LANHost(address: IPv4Address("192.168.50.66")!, openPorts: [80]),
        LANHost(address: IPv4Address("192.168.50.88")!, openPorts: [554]),
        LANHost(address: IPv4Address("192.168.50.105")!, openPorts: [62078]),
    ]
    static let services: [BonjourService] = [
        BonjourService(name: "ASUS RT-BE96U", type: "_http._tcp"),
        BonjourService(name: "HP LaserJet M111w", type: "_ipp._tcp"),
        BonjourService(name: "MacBook-Air", type: "_ssh._tcp"),
        BonjourService(name: "NAS-Home", type: "_smb._tcp"),
        BonjourService(name: "客廳 Apple TV", type: "_airplay._tcp"),
    ]
}

struct DemoWifiInfo: WifiInfoProviding {
    func requestAccess() async {}
    func current() async -> WifiAccess { .available(DemoData.wifi) }
    func interface() async -> InterfaceSnapshot { DemoData.interface }
}

struct DemoSpeedTest: SpeedTesting {
    var stepDelay: UInt64 = 120_000_000

    func run(progress: @escaping @MainActor (SpeedProgress) -> Void) async throws -> SpeedResult {
        await progress(SpeedProgress(phase: .latency))
        try await Task.sleep(nanoseconds: stepDelay * 3)
        for v in stride(from: 40.0, through: 452.0, by: 52) {
            try Task.checkCancellation()
            await progress(SpeedProgress(phase: .download, currentMbps: v))
            try await Task.sleep(nanoseconds: stepDelay)
        }
        for v in stride(from: 20.0, through: 228.0, by: 26) {
            try Task.checkCancellation()
            await progress(SpeedProgress(phase: .upload, currentMbps: v))
            try await Task.sleep(nanoseconds: stepDelay)
        }
        let pings: [Double?] = [6.2, 5.8, 7.1, 6.0, 6.4, 5.9, 8.3, 6.1, 6.0, 6.6]
        return SpeedResult(downloadMbps: 452, uploadMbps: 228, latency: LatencyStats(samples: pings),
                           server: "示範資料", date: Date())
    }
}

struct DemoLatencyProbe: LatencyProbing {
    func connectTime(host: String, port: UInt16, timeout: TimeInterval) async -> Double? {
        if host.hasSuffix(".invalid") { return nil }
        let base = host.hasPrefix("192.168.") ? 2.0 : (host.contains("apple") ? 9.5 : 6.0)
        return base + Double(abs(host.hashValue % 7)) / 10 + Double.random(in: 0...1.2)
    }
}

struct DemoLANScanner: LANScanning {
    var stepDelay: UInt64 = 8_000_000

    func browse(types: [String], for seconds: TimeInterval) async -> [BonjourService] { DemoData.services }

    func sweep(targets: [IPv4Address], ports: [UInt16], timeout: TimeInterval, progress: @escaping @MainActor (Int) -> Void) async -> [LANHost] {
        for i in stride(from: 16, through: targets.count, by: 16) {
            if Task.isCancelled { break }
            await progress(i)
            try? await Task.sleep(nanoseconds: stepDelay)
        }
        await progress(targets.count)
        let wanted = Set(targets)
        return DemoData.hosts.filter { wanted.contains($0.address) }.map { h in
            LANHost(address: h.address, openPorts: h.openPorts.filter(ports.contains))
        }.filter { !$0.openPorts.isEmpty }
    }
}

struct DemoDNSResolver: DNSResolving {
    func resolve(_ host: String) async throws -> DNSAnswer {
        guard HostInput.isValid(host) else { throw DNSError.invalidName }
        switch host.lowercased() {
        case "apple.com": return DNSAnswer(canonicalName: nil, ipv4: ["17.253.144.10"], ipv6: ["2620:149:af0::10"], milliseconds: 18)
        case "www.apple.com": return DNSAnswer(canonicalName: "www.apple.com.edgekey.net", ipv4: ["23.45.120.15"], ipv6: [], milliseconds: 22)
        case "google.com": return DNSAnswer(canonicalName: nil, ipv4: ["142.250.66.78"], ipv6: ["2404:6800:4012:5::200e"], milliseconds: 12)
        default: throw DNSError.notFound("示範模式只內建 apple.com、www.apple.com、google.com")
        }
    }
}
