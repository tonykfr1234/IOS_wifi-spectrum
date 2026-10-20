import Foundation

public struct IPv4Address: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let value: UInt32

    public init(_ value: UInt32) { self.value = value }

    public init?(_ text: String) {
        let parts = text.trimmingCharacters(in: .whitespaces).split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return nil }
        var v: UInt32 = 0
        for p in parts {
            guard !p.isEmpty, p.count <= 3, p.allSatisfy({ $0.isASCII && $0.isNumber }), let n = UInt32(p), n <= 255 else { return nil }
            v = v << 8 | n
        }
        value = v
    }

    public var description: String {
        [24, 16, 8, 0].map { String((value >> UInt32($0)) & 0xff) }.joined(separator: ".")
    }

    public var isPrivate: Bool {
        let a = value >> 24, b = (value >> 16) & 0xff
        return a == 10 || (a == 172 && (16...31).contains(b)) || (a == 192 && b == 168)
    }

    public static func < (l: IPv4Address, r: IPv4Address) -> Bool { l.value < r.value }
}

public enum SubnetError: Error, Equatable {
    case badAddress, badPrefix, nonContiguousMask
}

/// IPv4 network maths for the subnet calculator and the LAN sweep.
public struct Subnet: Equatable, Sendable {
    public let address: IPv4Address
    public let prefix: Int

    public init(address: IPv4Address, prefix: Int) throws {
        guard (0...32).contains(prefix) else { throw SubnetError.badPrefix }
        self.address = address
        self.prefix = prefix
    }

    /// Accepts "192.168.1.10/24" or "192.168.1.10 255.255.255.0".
    public init(parsing text: String) throws {
        let t = text.trimmingCharacters(in: .whitespaces)
        let pieces = t.split(whereSeparator: { $0 == "/" || $0 == " " }).map(String.init)
        guard let first = pieces.first, let ip = IPv4Address(first) else { throw SubnetError.badAddress }
        guard pieces.count == 2 else { throw SubnetError.badPrefix }
        if let p = Int(pieces[1]) {
            try self.init(address: ip, prefix: p)
        } else if let mask = IPv4Address(pieces[1]) {
            try self.init(address: ip, mask: mask)
        } else {
            throw SubnetError.badPrefix
        }
    }

    public init(address: IPv4Address, mask: IPv4Address) throws {
        let ones = mask.value.nonzeroBitCount
        let expected: UInt32 = ones == 0 ? 0 : UInt32.max << UInt32(32 - ones)
        guard mask.value == expected else { throw SubnetError.nonContiguousMask }
        try self.init(address: address, prefix: ones)
    }

    public var mask: IPv4Address { IPv4Address(prefix == 0 ? 0 : UInt32.max << UInt32(32 - prefix)) }
    public var network: IPv4Address { IPv4Address(address.value & mask.value) }
    public var broadcast: IPv4Address { IPv4Address(network.value | ~mask.value) }

    /// Usable hosts: /31 and /32 follow RFC 3021 (both addresses usable / single host).
    public var hostCount: UInt64 {
        switch prefix {
        case 32: return 1
        case 31: return 2
        default: return (UInt64(1) << UInt64(32 - prefix)) - 2
        }
    }

    public var firstHost: IPv4Address { prefix >= 31 ? network : IPv4Address(network.value + 1) }
    public var lastHost: IPv4Address { prefix >= 31 ? broadcast : IPv4Address(broadcast.value - 1) }

    public func contains(_ ip: IPv4Address) -> Bool { ip.value & mask.value == network.value }

    /// Hosts to probe on a LAN, skipping ourselves. Refuses networks larger than [limit] hosts.
    public func sweepTargets(excluding me: IPv4Address? = nil, limit: Int = 1024) -> [IPv4Address] {
        guard hostCount <= UInt64(limit) else { return [] }
        var out: [IPv4Address] = []
        var v = firstHost.value
        while v <= lastHost.value {
            if v != me?.value { out.append(IPv4Address(v)) }
            if v == UInt32.max { break }
            v += 1
        }
        return out
    }
}

public enum Ports {
    public static let common: [UInt16] = [21, 22, 23, 53, 80, 139, 443, 445, 548, 554, 631, 3389, 5000, 5001, 7000, 8080, 8443, 9100, 62078]

    /// Ports the LAN sweep probes on every host; small enough to finish a /24 quickly.
    public static let sweep: [UInt16] = [80, 443, 22, 445, 554, 62078]

    public static func service(_ port: UInt16) -> String {
        switch port {
        case 21: return "FTP"
        case 22: return "SSH"
        case 23: return "Telnet"
        case 53: return "DNS"
        case 80: return "HTTP"
        case 139: return "NetBIOS"
        case 443: return "HTTPS"
        case 445: return "SMB 檔案分享"
        case 548: return "AFP"
        case 554: return "RTSP 攝影機"
        case 631: return "IPP 列印"
        case 3389: return "遠端桌面"
        case 5000: return "NAS 管理"
        case 5001: return "NAS HTTPS"
        case 7000: return "AirPlay"
        case 8080: return "HTTP 替代"
        case 8443: return "HTTPS 替代"
        case 9100: return "RAW 列印"
        case 62078: return "iPhone 同步"
        default: return "未知服務"
        }
    }

    /// Parses "80", "80,443" or "8000-8010"; returns nil for anything malformed or over 1024 ports.
    public static func parse(_ text: String) -> [UInt16]? {
        var out = Set<UInt16>()
        for piece in text.split(separator: ",") {
            let p = piece.trimmingCharacters(in: .whitespaces)
            if let dash = p.firstIndex(of: "-") {
                guard let a = UInt16(p[..<dash]), let b = UInt16(p[p.index(after: dash)...]), a >= 1, a <= b else { return nil }
                guard Int(b) - Int(a) < 1024 else { return nil }
                for v in a...b { out.insert(v) }
            } else {
                guard let v = UInt16(p), v >= 1 else { return nil }
                out.insert(v)
            }
            if out.count > 1024 { return nil }
        }
        return out.isEmpty ? nil : out.sorted()
    }
}

/// Host names and IP literals accepted by the tools.
public enum HostInput {
    public static func isValid(_ text: String) -> Bool {
        let t = text.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, t.count <= 253 else { return false }
        if IPv4Address(t) != nil { return true }
        if t.contains(":") { return t.allSatisfy { $0.isHexDigit || $0 == ":" || $0 == "." } }
        let labels = t.split(separator: ".", omittingEmptySubsequences: false)
        if labels.allSatisfy({ $0.allSatisfy(\.isNumber) }) { return false }
        return labels.allSatisfy { l in
            !l.isEmpty && l.count <= 63 && l.first != "-" && l.last != "-" && l.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
        }
    }
}
