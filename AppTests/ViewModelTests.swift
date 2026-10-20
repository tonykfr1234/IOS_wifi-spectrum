import XCTest
import WifiSpectrumCore
@testable import WifiSpectrum

private struct FailingSpeedTest: SpeedTesting {
    var error: Error
    func run(progress: @escaping @MainActor (SpeedProgress) -> Void) async throws -> SpeedResult { throw error }
}

private struct SilentLatency: LatencyProbing {
    func connectTime(host: String, port: UInt16, timeout: TimeInterval) async -> Double? { nil }
}

private struct ScriptedWifi: WifiInfoProviding {
    var access: WifiAccess
    var iface: InterfaceSnapshot
    func requestAccess() async {}
    func current() async -> WifiAccess { access }
    func interface() async -> InterfaceSnapshot { iface }
}

@MainActor
final class ViewModelTests: XCTestCase {
    private func services(_ edit: (inout Services) -> Void = { _ in }) -> Services {
        var s = Services.demo(vendors: AppEnvironment.vendors, fast: true)
        edit(&s)
        return s
    }

    // MARK: Connection

    func testConnectionReadyShowsVendorAndSubnet() async {
        let m = ConnectionModel(services: services())
        await m.refresh()
        XCTAssertEqual(m.state, .ready(DemoData.wifi))
        XCTAssertTrue(m.vendor?.contains("ASUSTek") == true)
        XCTAssertEqual(m.subnet?.prefix, 24)
        XCTAssertEqual(m.subnet?.network.description, "192.168.50.0")
    }

    func testConnectionStates() async {
        let offline = InterfaceSnapshot(ipv4: nil, netmask: nil, ipv6: [], isWifi: false, isExpensive: true, isConstrained: false, supportsIPv6: false, hasDNS: true)
        for (access, expected) in [(WifiAccess.needsLocationPermission, ConnectionModel.State.needsPermission),
                                   (.locationDenied, .denied), (.notConnected, .notConnected)] {
            let m = ConnectionModel(services: services { $0.wifi = ScriptedWifi(access: access, iface: offline) })
            await m.refresh()
            XCTAssertEqual(m.state, expected)
            XCTAssertNil(m.subnet)
            XCTAssertNil(m.vendor)
        }
    }

    func testRandomizedBssidHasNoVendor() async {
        let w = WifiSnapshot(ssid: "Hotspot", bssid: "8a:2b:3c:4d:5e:6f", securityRaw: 2)
        let m = ConnectionModel(services: services { $0.wifi = ScriptedWifi(access: .available(w), iface: DemoData.interface) })
        await m.refresh()
        XCTAssertNil(m.vendor)
        XCTAssertTrue(m.randomizedBSSID)
    }

    // MARK: Speed test

    func testSpeedTestCompletes() async {
        let m = SpeedTestModel(services: services())
        m.start()
        XCTAssertTrue(m.isRunning)
        m.start()
        await m.waitUntilFinished()
        XCTAssertEqual(m.phase, .done)
        XCTAssertEqual(m.result?.downloadMbps, 452)
        XCTAssertEqual(m.history.count, 1)
        XCTAssertNotNil(m.result?.latency)
    }

    func testSpeedTestCancel() async {
        let m = SpeedTestModel(services: services { $0.speed = DemoSpeedTest(stepDelay: 50_000_000) })
        m.start()
        m.cancel()
        await m.waitUntilFinished()
        XCTAssertEqual(m.phase, .cancelled)
        XCTAssertNil(m.result)
        XCTAssertTrue(m.history.isEmpty)
    }

    func testSpeedTestFailureMessage() async {
        let m = SpeedTestModel(services: services { $0.speed = FailingSpeedTest(error: URLError(.notConnectedToInternet)) })
        m.start()
        await m.waitUntilFinished()
        XCTAssertEqual(m.phase, .failed)
        XCTAssertEqual(m.error, "沒有網路連線，請確認 Wi-Fi 或行動網路。")
    }

    func testSpeedHistoryIsCapped() async {
        let m = SpeedTestModel(services: services())
        for _ in 0..<25 {
            m.start()
            await m.waitUntilFinished()
        }
        XCTAssertEqual(m.history.count, 20)
    }

    // MARK: LAN

    func testLANScanFindsDemoHosts() async {
        let m = LANModel(services: services())
        m.scan()
        await m.waitUntilFinished()
        XCTAssertFalse(m.scanning)
        XCTAssertEqual(m.total, 253)
        XCTAssertEqual(m.progress, 253)
        XCTAssertEqual(m.hosts.map(\.address.description), ["192.168.50.1", "192.168.50.10", "192.168.50.23", "192.168.50.66", "192.168.50.88"])
        XCTAssertEqual(m.bonjour.count, 5)
        XCTAssertEqual(m.subnetText, "192.168.50.0/24")
    }

    func testLANWithoutWifi() async {
        let offline = InterfaceSnapshot(ipv4: nil, netmask: nil, ipv6: [], isWifi: false, isExpensive: true, isConstrained: false, supportsIPv6: false, hasDNS: true)
        let m = LANModel(services: services { $0.wifi = ScriptedWifi(access: .notConnected, iface: offline) })
        m.scan()
        await m.waitUntilFinished()
        XCTAssertEqual(m.message, "沒有連上 Wi-Fi，無法掃描區域網路。")
        XCTAssertTrue(m.hosts.isEmpty)
    }

    func testLANRefusesHugeNetwork() async {
        var big = DemoData.interface
        big.netmask = "255.255.0.0"
        let m = LANModel(services: services { $0.wifi = ScriptedWifi(access: .available(DemoData.wifi), iface: big) })
        m.scan()
        await m.waitUntilFinished()
        XCTAssertTrue(m.message?.contains("超過 1024") == true)
        XCTAssertTrue(m.hosts.isEmpty)
        XCTAssertEqual(m.bonjour.count, 5)
    }

    // MARK: Tools

    func testLatencyValidation() {
        let m = LatencyModel(services: services())
        m.host = "bad host"
        m.start()
        XCTAssertNotNil(m.error)
        XCTAssertFalse(m.running)
        m.host = "apple.com"
        m.portText = "0"
        m.start()
        XCTAssertEqual(m.error, "連接埠要是 1–65535。")
    }

    func testLatencyRun() async {
        let m = LatencyModel(services: services(), count: 3)
        m.start()
        await m.waitUntilFinished()
        XCTAssertEqual(m.samples.count, 3)
        XCTAssertEqual(m.stats?.received, 3)
        XCTAssertNil(m.error)
    }

    func testLatencyAllTimeouts() async {
        let m = LatencyModel(services: services { $0.latency = SilentLatency() }, count: 2)
        m.start()
        await m.waitUntilFinished()
        XCTAssertNil(m.stats)
        XCTAssertTrue(m.error?.contains("沒有回應") == true)
    }

    func testDNS() async {
        let m = DNSModel(services: services())
        await m.lookup()
        XCTAssertEqual(m.answer?.ipv4, ["17.253.144.10"])
        m.host = "nope.example"
        await m.lookup()
        XCTAssertNil(m.answer)
        XCTAssertNotNil(m.error)
        m.host = "-bad-"
        await m.lookup()
        XCTAssertEqual(m.error, "名稱格式不正確，例如 apple.com 或 8.8.8.8。")
    }

    func testPortScanDefaultsAndValidation() async {
        let m = PortScanModel(services: services())
        m.portsText = "1-65535"
        m.start()
        XCTAssertNotNil(m.error)
        m.portsText = ""
        m.host = "192.168.50.10"
        m.start()
        await m.waitUntilFinished()
        XCTAssertEqual(m.rows.count, Ports.common.count)
        XCTAssertEqual(m.rows.map(\.port), Ports.common.sorted())
    }

    func testPortScanAllClosed() async {
        let m = PortScanModel(services: services { $0.latency = SilentLatency() })
        m.portsText = "8000-8019"
        m.start()
        await m.waitUntilFinished()
        XCTAssertEqual(m.rows.count, 20)
        XCTAssertTrue(m.openRows.isEmpty)
    }

    // MARK: Gauge maths

    func testGaugeFraction() {
        XCTAssertEqual(SpeedGauge.fraction(0), 0)
        XCTAssertEqual(SpeedGauge.fraction(1000), 1, accuracy: 0.0001)
        XCTAssertEqual(SpeedGauge.fraction(5000), 1)
        XCTAssertEqual(SpeedGauge.fraction(100), 0.5, accuracy: 0.0001)
        XCTAssertLessThan(SpeedGauge.fraction(50), SpeedGauge.fraction(51))
    }
}
