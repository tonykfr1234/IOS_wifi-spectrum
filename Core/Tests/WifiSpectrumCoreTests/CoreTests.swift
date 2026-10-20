import XCTest
@testable import WifiSpectrumCore

final class ChannelsTests: XCTestCase {
    func testChannelNumbers() {
        XCTAssertEqual(Channels.channel(ofFrequency: 2412), 1)
        XCTAssertEqual(Channels.channel(ofFrequency: 2484), 14)
        XCTAssertEqual(Channels.channel(ofFrequency: 5180), 36)
        XCTAssertEqual(Channels.channel(ofFrequency: 5885), 177)
        XCTAssertEqual(Channels.channel(ofFrequency: 4920), 184)
        XCTAssertEqual(Channels.channel(ofFrequency: 5935), 2)
        XCTAssertEqual(Channels.channel(ofFrequency: 5955), 1)
        XCTAssertEqual(Channels.channel(ofFrequency: 7115), 233)
        XCTAssertNil(Channels.channel(ofFrequency: 2413))
        XCTAssertNil(Channels.channel(ofFrequency: 0))
        XCTAssertNil(Channels.channel(ofFrequency: -5))
        XCTAssertNil(Channels.band(ofFrequency: 60480))
    }

    func testRoundTripEveryCandidate() {
        for band in Band.allCases {
            for ch in Channels.candidateChannels(band) {
                let f = Channels.frequency(band: band, channel: ch)
                XCTAssertEqual(Channels.channel(ofFrequency: f), ch, "\(band) \(ch)")
                XCTAssertEqual(Channels.band(ofFrequency: f), band, "\(band) \(ch)")
            }
        }
    }

    func testPSC() {
        let psc = (1...233).filter(Channels.isPreferredScanningChannel)
        XCTAssertEqual(psc.count, 15)
        XCTAssertEqual(psc.first, 5)
        XCTAssertEqual(psc.last, 229)
    }

    /// Same expectations as the Android ChannelsTest, so both apps agree.
    func testPlansMatchAndroid() throws {
        func plan(_ b: Band, _ ch: Int, _ w: ChannelWidth) throws -> ChannelPlan { try XCTUnwrap(ChannelPlan(band: b, channel: ch, width: w)) }
        XCTAssertEqual(try plan(.ghz2_4, 6, .mhz20).lowMHz, 2427)
        XCTAssertEqual(try plan(.ghz2_4, 1, .mhz40).lowMHz, 2402)
        XCTAssertEqual(try plan(.ghz2_4, 1, .mhz40).highMHz, 2442)
        XCTAssertEqual(try plan(.ghz2_4, 11, .mhz40).lowMHz, 2432)
        let p80 = try plan(.ghz5, 44, .mhz80)
        XCTAssertEqual([p80.lowMHz, p80.highMHz, p80.centerChannel], [5170, 5250, 42])
        let p160 = try plan(.ghz5, 36, .mhz160)
        XCTAssertEqual([p160.lowMHz, p160.highMHz, p160.centerChannel], [5170, 5330, 50])
        XCTAssertTrue(p160.hasDFS)
        let p320 = try plan(.ghz6, 37, .mhz320)
        XCTAssertEqual([p320.lowMHz, p320.highMHz, p320.centerChannel], [5945, 6265, 31])
        XCTAssertEqual(p320.coveredChannels, Array(stride(from: 1, through: 61, by: 4)))
        XCTAssertTrue(p320.isPSC)
        let six160 = try plan(.ghz6, 37, .mhz160)
        XCTAssertEqual([six160.lowMHz, six160.highMHz], [6105, 6265])
    }

    func testEveryPlanContainsPrimaryAndHasRightWidth() {
        for band in Band.allCases {
            for ch in Channels.candidateChannels(band) {
                for w in ChannelWidth.allowed(in: band) {
                    guard let p = ChannelPlan(band: band, channel: ch, width: w) else { return XCTFail("\(band) \(ch) \(w)") }
                    XCTAssertEqual(p.highMHz - p.lowMHz, w.rawValue)
                    XCTAssertTrue(p.lowMHz <= p.primaryFrequency - 10 && p.primaryFrequency + 10 <= p.highMHz, "\(band) \(ch) \(w)")
                    XCTAssertTrue(p.coveredChannels.contains(ch))
                }
            }
        }
    }

    func testInvalidPlans() {
        XCTAssertNil(ChannelPlan(band: .ghz2_4, channel: 6, width: .mhz80))
        XCTAssertNil(ChannelPlan(band: .ghz5, channel: 36, width: .mhz320))
        XCTAssertNil(ChannelPlan(band: .ghz5, channel: 37, width: .mhz20))
        XCTAssertNil(ChannelPlan(band: .ghz6, channel: 0, width: .mhz20))
    }

    func testUNII() {
        XCTAssertEqual(Channels.uniiBand(band: .ghz5, channel: 36), "UNII-1")
        XCTAssertEqual(Channels.uniiBand(band: .ghz5, channel: 100), "UNII-2C")
        XCTAssertEqual(Channels.uniiBand(band: .ghz5, channel: 173), "UNII-4")
        XCTAssertEqual(Channels.uniiBand(band: .ghz6, channel: 37), "UNII-5")
        XCTAssertEqual(Channels.uniiBand(band: .ghz6, channel: 233), "UNII-8")
        XCTAssertNil(Channels.uniiBand(band: .ghz2_4, channel: 6))
    }
}

final class NetworkTests: XCTestCase {
    func testIPv4Parsing() {
        XCTAssertEqual(IPv4("192.168.1.10")?.description, "192.168.1.10")
        XCTAssertEqual(IPv4(" 10.0.0.1 ")?.value, 0x0A00_0001)
        for bad in ["", "1.2.3", "1.2.3.4.5", "256.1.1.1", "a.b.c.d", "+1.2.3.4", "1..2.3", "1.2.3.4 ", "01234.1.1.1", "１.2.3.4"] where bad != "1.2.3.4 " {
            XCTAssertNil(IPv4(bad), bad)
        }
        XCTAssertTrue(IPv4("172.20.1.1")!.isPrivate)
        XCTAssertFalse(IPv4("8.8.8.8")!.isPrivate)
    }

    func testSubnet24() throws {
        let s = try Subnet(parsing: "192.168.1.105/24")
        XCTAssertEqual(s.network.description, "192.168.1.0")
        XCTAssertEqual(s.broadcast.description, "192.168.1.255")
        XCTAssertEqual(s.mask.description, "255.255.255.0")
        XCTAssertEqual(s.hostCount, 254)
        XCTAssertEqual(s.firstHost.description, "192.168.1.1")
        XCTAssertEqual(s.lastHost.description, "192.168.1.254")
        XCTAssertTrue(s.contains(IPv4("192.168.1.200")!))
        XCTAssertFalse(s.contains(IPv4("192.168.2.1")!))
        let targets = s.sweepTargets(excluding: IPv4("192.168.1.105"))
        XCTAssertEqual(targets.count, 253)
        XCTAssertFalse(targets.contains(IPv4("192.168.1.105")!))
    }

    func testMaskForm() throws {
        let s = try Subnet(parsing: "10.1.2.3 255.255.240.0")
        XCTAssertEqual(s.prefix, 20)
        XCTAssertEqual(s.network.description, "10.1.0.0")
        XCTAssertThrowsError(try Subnet(parsing: "10.1.2.3 255.0.255.0")) { XCTAssertEqual($0 as? SubnetError, .nonContiguousMask) }
    }

    func testEdgePrefixes() throws {
        XCTAssertEqual(try Subnet(parsing: "1.2.3.4/32").hostCount, 1)
        XCTAssertEqual(try Subnet(parsing: "1.2.3.4/31").hostCount, 2)
        XCTAssertEqual(try Subnet(parsing: "1.2.3.4/0").hostCount, 4_294_967_294)
        XCTAssertEqual(try Subnet(parsing: "255.255.255.255/32").sweepTargets().count, 1)
        XCTAssertTrue(try Subnet(parsing: "10.0.0.1/8").sweepTargets().isEmpty, "huge networks are refused")
        XCTAssertThrowsError(try Subnet(parsing: "1.2.3.4/33"))
        XCTAssertThrowsError(try Subnet(parsing: "1.2.3.4"))
        XCTAssertThrowsError(try Subnet(parsing: "x/24"))
    }

    func testPorts() {
        XCTAssertEqual(Ports.parse("80"), [80])
        XCTAssertEqual(Ports.parse("443, 80,80"), [80, 443])
        XCTAssertEqual(Ports.parse("8000-8003"), [8000, 8001, 8002, 8003])
        XCTAssertNil(Ports.parse(""))
        XCTAssertNil(Ports.parse("0"))
        XCTAssertNil(Ports.parse("70000"))
        XCTAssertNil(Ports.parse("10-5"))
        XCTAssertNil(Ports.parse("1-65535"))
        XCTAssertNil(Ports.parse("abc"))
        XCTAssertEqual(Ports.service(62078), "iPhone 同步")
        XCTAssertEqual(Ports.service(1), "未知服務")
    }

    func testHostInput() {
        for ok in ["apple.com", "8.8.8.8", "router.local", "a-b.c", "2001:db8::1"] { XCTAssertTrue(HostInput.isValid(ok), ok) }
        for bad in ["", " ", "-a.com", "a..com", "a b.com", "1.2.3.999", "測試.com", String(repeating: "a", count: 254)] { XCTAssertFalse(HostInput.isValid(bad), bad) }
    }
}

final class MeasurementTests: XCTestCase {
    func testThroughput() {
        XCTAssertEqual(Throughput.mbps(bytes: 25_000_000, seconds: 1), 200, accuracy: 0.0001)
        XCTAssertEqual(Throughput.mbps(bytes: 0, seconds: 1), 0)
        XCTAssertEqual(Throughput.mbps(bytes: 10, seconds: 0), 0)
        XCTAssertEqual(Throughput.mbps(bytes: 10, seconds: .infinity), 0)
        XCTAssertEqual(Throughput.estimate([100, 5, 300]), 100)
        XCTAssertEqual(Throughput.estimate([100, 200]), 150)
        XCTAssertEqual(Throughput.estimate([.nan, -1, 0]), 0)
        XCTAssertEqual(Throughput.format(0), "—")
        XCTAssertEqual(Throughput.format(12.34), "12.3")
        XCTAssertEqual(Throughput.format(456.7), "457")
    }

    func testLatencyStats() throws {
        let s = try XCTUnwrap(LatencyStats(samples: [10, 12, nil, 11, 20]))
        XCTAssertEqual(s.sent, 5)
        XCTAssertEqual(s.received, 4)
        XCTAssertEqual(s.lossPercent, 20, accuracy: 0.001)
        XCTAssertEqual(s.minMs, 10)
        XCTAssertEqual(s.maxMs, 20)
        XCTAssertEqual(s.avgMs, 13.25, accuracy: 0.001)
        XCTAssertEqual(s.medianMs, 11.5, accuracy: 0.001)
        XCTAssertEqual(s.jitterMs, (2 + 1 + 9) / 3, accuracy: 0.001)
        XCTAssertNil(LatencyStats(samples: []))
        XCTAssertNil(LatencyStats(samples: [nil, nil]))
        XCTAssertEqual(LatencyStats(samples: [5])?.jitterMs, 0)
    }

    func testSecurityLabels() {
        XCTAssertEqual(WifiSecurity.label(rawValue: 2), "個人（WPA2／WPA3）")
        XCTAssertEqual(WifiSecurity.label(rawValue: 99), "未知")
        XCTAssertTrue(WifiSecurity.isWeak(rawValue: 0))
        XCTAssertFalse(WifiSecurity.isWeak(rawValue: 3))
    }
}

final class VendorTests: XCTestCase {
    static let db = VendorDatabase.bundled()

    func testBundledRegistryLoads() { XCTAssertGreaterThan(Self.db.count, 30_000) }
    func testKnownVendor() { XCTAssertTrue(Self.db.lookup("00:00:0c:12:34:56")?.contains("Cisco") == true) }
    func testUnpaddedIOSBssid() { XCTAssertEqual(Self.db.lookup("4:d9:f5:3a:11:20"), Self.db.lookup("04:d9:f5:3a:11:20")) }
    func testRandomizedMac() { XCTAssertNil(Self.db.lookup("02:00:0c:12:34:56")) }
    func testGarbage() {
        for s in ["", "xyz", "::::", "zz:zz:zz:zz:zz:zz", "0"] { XCTAssertNil(Self.db.lookup(s), s) }
    }
    func testPadding() { XCTAssertEqual(MacAddress.padded("4:D9:F5:3A:1:20"), "04:d9:f5:3a:01:20") }

    func testLookupFuzz() {
        var rng = SystemRandomNumberGenerator()
        let chars = Array("0123456789abcdefABCDEF:-xyz ")
        for _ in 0..<20_000 {
            let s = String((0..<Int.random(in: 0...25, using: &rng)).map { _ in chars.randomElement(using: &rng)! })
            _ = Self.db.lookup(s)
        }
    }
}
