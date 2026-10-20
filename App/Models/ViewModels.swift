import Foundation
import WifiSpectrumCore

enum UserMessage {
    static func describe(_ error: Error) -> String {
        if let e = error as? URLError {
            switch e.code {
            case .notConnectedToInternet, .networkConnectionLost: return "沒有網路連線，請確認 Wi-Fi 或行動網路。"
            case .timedOut: return "伺服器回應逾時，請稍後再試。"
            case .cannotFindHost, .dnsLookupFailed: return "找不到測速伺服器，請檢查 DNS 設定。"
            case .cancelled: return "已取消。"
            default: return "網路錯誤（\(e.code.rawValue)），請稍後再試。"
            }
        }
        if let e = error as? DNSError {
            switch e {
            case .invalidName: return "名稱格式不正確，例如 apple.com 或 8.8.8.8。"
            case .notFound(let why): return "查不到這個名稱：\(why)"
            }
        }
        return "發生錯誤：\(error.localizedDescription)"
    }
}

@MainActor
final class ConnectionModel: ObservableObject {
    enum State: Equatable {
        case loading
        case ready(WifiSnapshot)
        case needsPermission
        case denied
        case notConnected
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var interface: InterfaceSnapshot?
    @Published private(set) var subnet: Subnet?
    let services: Services

    init(services: Services) { self.services = services }

    var vendor: String? {
        guard case let .ready(w) = state else { return nil }
        return services.vendors.lookup(w.bssid)
    }

    var randomizedBSSID: Bool {
        guard case let .ready(w) = state else { return false }
        return MacAddress.isLocallyAdministered(w.bssid)
    }

    func refresh() async {
        switch await services.wifi.current() {
        case .available(let w): state = .ready(w)
        case .needsLocationPermission: state = .needsPermission
        case .locationDenied: state = .denied
        case .notConnected: state = .notConnected
        }
        let i = await services.wifi.interface()
        interface = i
        if let ip = i.ipv4.flatMap(IPv4.init), let mask = i.netmask.flatMap(IPv4.init) {
            subnet = try? Subnet(address: ip, mask: mask)
        } else {
            subnet = nil
        }
    }

    func requestPermission() async {
        await services.wifi.requestAccess()
        await refresh()
    }
}

@MainActor
final class SpeedTestModel: ObservableObject {
    @Published private(set) var phase: SpeedPhase = .idle
    @Published private(set) var live: Double = 0
    @Published private(set) var result: SpeedResult?
    @Published private(set) var history: [SpeedResult] = []
    @Published private(set) var error: String?
    private var task: Task<Void, Never>?
    let services: Services

    init(services: Services) { self.services = services }

    var isRunning: Bool { [.latency, .download, .upload].contains(phase) }

    func start() {
        guard !isRunning else { return }
        error = nil
        result = nil
        live = 0
        phase = .latency
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let r = try await services.speed.run { [weak self] p in
                    guard let self, self.isRunning else { return }
                    self.phase = p.phase
                    self.live = p.currentMbps
                }
                if Task.isCancelled { phase = .cancelled; return }
                result = r
                history = Array(([r] + history).prefix(20))
                phase = .done
            } catch {
                if Task.isCancelled || error is CancellationError || (error as? URLError)?.code == .cancelled {
                    phase = .cancelled
                } else {
                    self.error = UserMessage.describe(error)
                    phase = .failed
                }
            }
        }
    }

    func cancel() {
        task?.cancel()
        if isRunning { phase = .cancelled }
    }

    /// Waits for the running test; used by tests.
    func waitUntilFinished() async { await task?.value }
}

@MainActor
final class LANModel: ObservableObject {
    static let bonjourTypes = ["_http._tcp", "_ipp._tcp", "_airplay._tcp", "_raop._tcp", "_smb._tcp", "_ssh._tcp",
                               "_googlecast._tcp", "_hap._tcp", "_printer._tcp", "_companion-link._tcp"]

    @Published private(set) var scanning = false
    @Published private(set) var progress = 0
    @Published private(set) var total = 0
    @Published private(set) var hosts: [LANHost] = []
    @Published private(set) var bonjour: [BonjourService] = []
    @Published private(set) var message: String?
    @Published private(set) var subnetText: String?
    private var task: Task<Void, Never>?
    let services: Services

    init(services: Services) { self.services = services }

    func scan() {
        guard !scanning else { return }
        scanning = true
        message = nil
        hosts = []
        bonjour = []
        progress = 0
        task = Task { [weak self] in
            guard let self else { return }
            defer { scanning = false }
            let i = await services.wifi.interface()
            guard i.isWifi, let ip = i.ipv4.flatMap(IPv4.init), let mask = i.netmask.flatMap(IPv4.init),
                  let subnet = try? Subnet(address: ip, mask: mask) else {
                message = "沒有連上 Wi-Fi，無法掃描區域網路。"
                return
            }
            subnetText = "\(subnet.network)/\(subnet.prefix)"
            let targets = subnet.sweepTargets(excluding: ip, limit: 1024)
            guard !targets.isEmpty else {
                message = "這個網段有 \(subnet.hostCount) 個位址，超過 1024 個，只顯示 Bonjour 裝置。"
                bonjour = await services.lan.browse(types: Self.bonjourTypes, for: 4)
                return
            }
            total = targets.count
            let lan = services.lan
            let types = Self.bonjourTypes
            async let found = lan.sweep(targets: targets, ports: Ports.sweep, timeout: 0.5) { [weak self] n in self?.progress = n }
            async let names = lan.browse(types: types, for: 4)
            let (h, b) = await (found, names)
            if Task.isCancelled { message = "已停止掃描。" }
            hosts = h
            bonjour = b
            if h.isEmpty && b.isEmpty && !Task.isCancelled {
                message = "沒有裝置回應。請確認已在「設定 → 隱私權與安全性 → 本地網路」允許這個 App。"
            }
        }
    }

    func stop() { task?.cancel() }

    func waitUntilFinished() async { await task?.value }
}

@MainActor
final class LatencyModel: ObservableObject {
    @Published var host = "apple.com"
    @Published var portText = "443"
    @Published private(set) var samples: [Double?] = []
    @Published private(set) var running = false
    @Published private(set) var error: String?
    let services: Services
    let count: Int
    private var task: Task<Void, Never>?

    init(services: Services, count: Int = 10) {
        self.services = services
        self.count = count
    }

    var stats: LatencyStats? { LatencyStats(samples: samples) }

    func start() {
        guard !running else { return }
        let h = host.trimmingCharacters(in: .whitespaces)
        guard HostInput.isValid(h) else { error = "主機格式不正確，例如 apple.com 或 192.168.1.1。"; return }
        guard let port = UInt16(portText.trimmingCharacters(in: .whitespaces)), port > 0 else { error = "連接埠要是 1–65535。"; return }
        error = nil
        samples = []
        running = true
        task = Task { [weak self] in
            guard let self else { return }
            defer { running = false }
            for _ in 0..<count where !Task.isCancelled {
                let v = await services.latency.connectTime(host: h, port: port, timeout: 2)
                samples.append(v)
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            if samples.allSatisfy({ $0 == nil }) { error = "\(h):\(port) 沒有回應，可能主機不存在、連接埠關閉或被防火牆擋下。" }
        }
    }

    func stop() { task?.cancel() }
    func waitUntilFinished() async { await task?.value }
}

@MainActor
final class DNSModel: ObservableObject {
    @Published var host = "apple.com"
    @Published private(set) var answer: DNSAnswer?
    @Published private(set) var error: String?
    @Published private(set) var running = false
    let services: Services

    init(services: Services) { self.services = services }

    func lookup() async {
        let h = host.trimmingCharacters(in: .whitespaces)
        running = true
        defer { running = false }
        do {
            answer = try await services.dns.resolve(h)
            error = nil
        } catch {
            answer = nil
            self.error = UserMessage.describe(error)
        }
    }
}

@MainActor
final class PortScanModel: ObservableObject {
    struct Row: Equatable, Identifiable {
        var port: UInt16
        var open: Bool
        var id: UInt16 { port }
    }

    @Published var host = "192.168.1.1"
    @Published var portsText = ""
    @Published private(set) var rows: [Row] = []
    @Published private(set) var running = false
    @Published private(set) var done = 0
    @Published private(set) var total = 0
    @Published private(set) var error: String?
    let services: Services
    private var task: Task<Void, Never>?

    init(services: Services) { self.services = services }

    var openRows: [Row] { rows.filter(\.open) }

    func start() {
        guard !running else { return }
        let h = host.trimmingCharacters(in: .whitespaces)
        guard HostInput.isValid(h) else { error = "主機格式不正確。"; return }
        let ports: [UInt16]
        if portsText.trimmingCharacters(in: .whitespaces).isEmpty {
            ports = Ports.common
        } else if let p = Ports.parse(portsText) {
            ports = p
        } else {
            error = "連接埠格式：80、80,443 或 8000-8010，一次最多 1024 個。"
            return
        }
        error = nil
        rows = []
        done = 0
        total = ports.count
        running = true
        task = Task { [weak self] in
            guard let self else { return }
            defer { running = false }
            let probe = services.latency
            var index = 0
            while index < ports.count, !Task.isCancelled {
                let slice = Array(ports[index..<min(index + 8, ports.count)])
                index += slice.count
                let results = await withTaskGroup(of: Row.self) { group -> [Row] in
                    for p in slice {
                        group.addTask { Row(port: p, open: await probe.connectTime(host: h, port: p, timeout: 1) != nil) }
                    }
                    var out: [Row] = []
                    for await r in group { out.append(r) }
                    return out
                }
                rows = (rows + results).sorted { $0.port < $1.port }
                done = rows.count
            }
        }
    }

    func stop() { task?.cancel() }
    func waitUntilFinished() async { await task?.value }
}
