import Foundation

public enum Band: String, CaseIterable, Sendable, Identifiable {
    case ghz2_4 = "2.4 GHz"
    case ghz5 = "5 GHz"
    case ghz6 = "6 GHz"

    public var id: String { rawValue }
    public var label: String { rawValue }
}

public enum ChannelWidth: Int, CaseIterable, Sendable, Identifiable {
    case mhz20 = 20, mhz40 = 40, mhz80 = 80, mhz160 = 160, mhz320 = 320

    public var id: Int { rawValue }
    public var label: String { "\(rawValue) MHz" }

    /// Widths the band's channel plan allows.
    public static func allowed(in band: Band) -> [ChannelWidth] {
        switch band {
        case .ghz2_4: return [.mhz20, .mhz40]
        case .ghz5: return [.mhz20, .mhz40, .mhz80, .mhz160]
        case .ghz6: return allCases
        }
    }
}

/// Same channel rules as the Android app (core/Channels.kt), so both platforms agree.
public enum Channels {
    public static func band(ofFrequency f: Int) -> Band? {
        switch f {
        case 2401...2495: return .ghz2_4
        case 4900...5900: return .ghz5
        case 5925...7125: return .ghz6
        default: return nil
        }
    }

    /// Primary 20 MHz channel number, or nil when the frequency is off the channel raster.
    public static func channel(ofFrequency f: Int) -> Int? {
        if f == 2484 { return 14 }
        if (2412...2472).contains(f), (f - 2407) % 5 == 0 { return (f - 2407) / 5 }
        if (4910...4980).contains(f), f % 5 == 0 { return (f - 4000) / 5 }
        if (5000...5895).contains(f), f % 5 == 0 { return (f - 5000) / 5 }
        if f == 5935 { return 2 }
        if (5955...7115).contains(f), (f - 5950) % 5 == 0 { return (f - 5950) / 5 }
        return nil
    }

    public static func frequency(band: Band, channel: Int) -> Int {
        switch band {
        case .ghz2_4: return channel == 14 ? 2484 : 2407 + 5 * channel
        case .ghz5: return channel >= 182 ? 4000 + 5 * channel : 5000 + 5 * channel
        case .ghz6: return channel == 2 ? 5935 : 5950 + 5 * channel
        }
    }

    public static func candidateChannels(_ band: Band) -> [Int] {
        switch band {
        case .ghz2_4: return Array(1...13)
        case .ghz5: return Array(stride(from: 36, through: 64, by: 4)) + Array(stride(from: 100, through: 144, by: 4)) + Array(stride(from: 149, through: 177, by: 4))
        case .ghz6: return Array(stride(from: 1, through: 233, by: 4))
        }
    }

    /// 6 GHz Preferred Scanning Channels: 5, 21, 37 … 229.
    public static func isPreferredScanningChannel(_ channel: Int) -> Bool {
        (5...229).contains(channel) && channel % 16 == 5
    }

    /// 5 GHz channels that require radar detection.
    public static func isDFS(_ channel: Int) -> Bool { (52...144).contains(channel) }

    /// UNII sub-band name, e.g. "UNII-1".
    public static func uniiBand(band: Band, channel: Int) -> String? {
        switch band {
        case .ghz2_4: return nil
        case .ghz5:
            switch channel {
            case 36...48: return "UNII-1"
            case 52...64: return "UNII-2A"
            case 100...144: return "UNII-2C"
            case 149...165: return "UNII-3"
            case 169...177: return "UNII-4"
            default: return nil
            }
        case .ghz6:
            switch channel {
            case 1...93: return "UNII-5"
            case 97...113: return "UNII-6"
            case 117...185: return "UNII-7"
            case 189...233: return "UNII-8"
            default: return nil
            }
        }
    }

    /// Centre frequency of the standard block that contains [primary] for [widthMHz].
    public static func inferCenter(band: Band, primary: Int, widthMHz: Int) -> Int {
        guard let ch = channel(ofFrequency: primary), widthMHz > 20 else { return primary }
        let k = widthMHz / 20
        switch band {
        case .ghz2_4:
            return ch <= 7 ? primary + 10 : primary - 10
        case .ghz5:
            let base = ch >= 149 ? 149 : 36
            if ch < base || ch >= 182 { return primary }
            let start = base + 4 * k * ((ch - base) / 4 / k)
            return frequency(band: band, channel: start + 2 * (k - 1))
        case .ghz6:
            if ch == 2 { return primary }
            let start = 1 + 4 * k * ((ch - 1) / 4 / k)
            return frequency(band: band, channel: start + 2 * (k - 1))
        }
    }
}

/// Everything the channel calculator shows for one band/channel/width choice.
public struct ChannelPlan: Equatable, Sendable {
    public let band: Band
    public let primaryChannel: Int
    public let width: ChannelWidth
    public let primaryFrequency: Int
    public let lowMHz: Int
    public let highMHz: Int
    public let centerChannel: Int
    public let coveredChannels: [Int]
    public let isPSC: Bool
    public let hasDFS: Bool
    public let unii: String?

    public var centerFrequency: Int { (lowMHz + highMHz) / 2 }

    public init?(band: Band, channel: Int, width: ChannelWidth) {
        guard Channels.candidateChannels(band).contains(channel), ChannelWidth.allowed(in: band).contains(width) else { return nil }
        let f = Channels.frequency(band: band, channel: channel)
        let center = width == .mhz20 ? f : Channels.inferCenter(band: band, primary: f, widthMHz: width.rawValue)
        self.band = band
        self.primaryChannel = channel
        self.width = width
        self.primaryFrequency = f
        self.lowMHz = center - width.rawValue / 2
        self.highMHz = center + width.rawValue / 2
        self.centerChannel = Channels.channel(ofFrequency: center) ?? channel
        let low = lowMHz, high = highMHz
        self.coveredChannels = Channels.candidateChannels(band).filter { ch in
            let cf = Channels.frequency(band: band, channel: ch)
            return cf - 10 >= low && cf + 10 <= high
        }
        self.isPSC = band == .ghz6 && Channels.isPreferredScanningChannel(channel)
        self.hasDFS = band == .ghz5 && coveredChannels.contains(where: Channels.isDFS)
        self.unii = Channels.uniiBand(band: band, channel: channel)
    }
}
