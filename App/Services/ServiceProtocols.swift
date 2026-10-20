import Foundation
import WifiSpectrumCore

/// What iOS lets an app know about the current Wi-Fi network.
struct WifiSnapshot: Equatable {
    var ssid: String
    var bssid: String
    /// NEHotspotNetworkSecurityType raw value; nil before iOS 15.
    var securityRaw: Int?
}

struct InterfaceSnapshot: Equatable {
    var ipv4: String?
    var netmask: String?
    var ipv6: [String]
    var isWifi: Bool
    var isExpensive: Bool
    var isConstrained: Bool
    var supportsIPv6: Bool
    var hasDNS: Bool
}

enum WifiAccess: Equatable {
    case available(WifiSnapshot)
    case needsLocationPermission
    case locationDenied
    case notConnected
}

protocol WifiInfoProviding {
    func requestAccess() async
    func current() async -> WifiAccess
    func interface() async -> InterfaceSnapshot
}

enum SpeedPhase: String, Equatable {
    case idle, latency, download, upload, done, failed, cancelled
}

struct SpeedProgress: Equatable {
    var phase: SpeedPhase
    var currentMbps: Double = 0
}

struct SpeedResult: Equatable {
    var downloadMbps: Double
    var uploadMbps: Double
    var latency: LatencyStats?
    var server: String
    var date: Date
}

protocol SpeedTesting {
    func run(progress: @escaping @MainActor (SpeedProgress) -> Void) async throws -> SpeedResult
}

protocol LatencyProbing {
    /// TCP connect time in milliseconds, or nil on timeout/refusal.
    func connectTime(host: String, port: UInt16, timeout: TimeInterval) async -> Double?
}

struct LANHost: Equatable, Identifiable {
    var address: IPv4Address
    var openPorts: [UInt16]
    var id: UInt32 { address.value }
}

struct BonjourService: Equatable, Identifiable, Hashable {
    var name: String
    var type: String
    var id: String { type + "/" + name }
}

protocol LANScanning {
    func browse(types: [String], for seconds: TimeInterval) async -> [BonjourService]
    func sweep(targets: [IPv4Address], ports: [UInt16], timeout: TimeInterval, progress: @escaping @MainActor (Int) -> Void) async -> [LANHost]
}

struct DNSAnswer: Equatable {
    var canonicalName: String?
    var ipv4: [String]
    var ipv6: [String]
    var milliseconds: Double
}

enum DNSError: Error, Equatable {
    case invalidName
    case notFound(String)
}

protocol DNSResolving {
    func resolve(_ host: String) async throws -> DNSAnswer
}

/// Bundle of real or demo services injected into the view models.
struct Services {
    var wifi: WifiInfoProviding
    var speed: SpeedTesting
    var latency: LatencyProbing
    var lan: LANScanning
    var dns: DNSResolving
    var vendors: VendorDatabase
    var isDemo: Bool
}
