import Foundation

public enum Throughput {
    /// Megabits per second; 0 for empty or non-positive durations.
    public static func mbps(bytes: Int, seconds: Double) -> Double {
        guard bytes > 0, seconds > 0, seconds.isFinite else { return 0 }
        return Double(bytes) * 8 / seconds / 1_000_000
    }

    /// Speed-test estimate: median of the per-transfer rates, so one stalled transfer does not dominate.
    public static func estimate(_ samples: [Double]) -> Double {
        let clean = samples.filter { $0.isFinite && $0 > 0 }.sorted()
        guard !clean.isEmpty else { return 0 }
        let mid = clean.count / 2
        return clean.count % 2 == 1 ? clean[mid] : (clean[mid - 1] + clean[mid]) / 2
    }

    public static func format(_ mbps: Double) -> String {
        if mbps <= 0 { return "—" }
        return mbps < 100 ? String(format: "%.1f", mbps) : String(format: "%.0f", mbps)
    }
}

/// Round-trip statistics from a series of timings in milliseconds; nil entries are losses.
public struct LatencyStats: Equatable, Sendable {
    public let sent: Int
    public let received: Int
    public let minMs: Double
    public let avgMs: Double
    public let maxMs: Double
    public let medianMs: Double
    /// Mean absolute difference between consecutive successful samples (RFC 3550 style, unsmoothed).
    public let jitterMs: Double

    public var lossPercent: Double { sent == 0 ? 0 : Double(sent - received) / Double(sent) * 100 }

    public init?(samples: [Double?]) {
        let ok = samples.compactMap { $0 }.filter { $0.isFinite && $0 >= 0 }
        guard !samples.isEmpty, !ok.isEmpty else { return nil }
        sent = samples.count
        received = ok.count
        minMs = ok.min()!
        maxMs = ok.max()!
        avgMs = ok.reduce(0, +) / Double(ok.count)
        let s = ok.sorted()
        medianMs = s.count % 2 == 1 ? s[s.count / 2] : (s[s.count / 2 - 1] + s[s.count / 2]) / 2
        jitterMs = ok.count < 2 ? 0 : zip(ok, ok.dropFirst()).map { abs($1 - $0) }.reduce(0, +) / Double(ok.count - 1)
    }
}

public enum WifiSecurity {
    /// Labels for NEHotspotNetworkSecurityType raw values (open, WEP, personal, enterprise, unknown).
    public static func label(rawValue: Int) -> String {
        switch rawValue {
        case 0: return "開放"
        case 1: return "WEP"
        case 2: return "個人（WPA2／WPA3）"
        case 3: return "企業（802.1X）"
        default: return "未知"
        }
    }

    public static func isWeak(rawValue: Int) -> Bool { rawValue == 0 || rawValue == 1 }
}
