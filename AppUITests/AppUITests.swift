import XCTest

/// Drives the app in demo mode on the simulator and saves screenshots to $SCREENSHOT_DIR
/// (CI passes TEST_RUNNER_SCREENSHOT_DIR, which xcodebuild forwards without the prefix).
final class AppUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-demo", "-uiTesting"]
        app.launch()
    }

    private func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !dir.isEmpty {
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try? png.write(to: URL(fileURLWithPath: dir).appendingPathComponent(name + ".png"))
        }
    }

    /// Any element whose label contains [text]; SwiftUI may expose combined rows as different element types.
    private func any(containing text: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func tab(_ label: String) {
        app.tabBars.buttons[label].tap()
    }

    func test01Connection() {
        XCTAssertTrue(app.staticTexts["ssid"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["ssid"].label, "Home-BE")
        XCTAssertTrue(app.staticTexts["demoBanner"].exists)
        XCTAssertTrue(any(containing: "ASUSTek").waitForExistence(timeout: 5))
        shot("01_connection")
    }

    func test02SpeedTest() {
        tab("測速")
        let button = app.buttons["speedButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        let done = app.staticTexts["speedPhase"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        let finished = NSPredicate(format: "label == '完成 · 下載速度'")
        expectation(for: finished, evaluatedWith: done)
        waitForExpectations(timeout: 30)
        XCTAssertEqual(app.staticTexts["gaugeValue"].label, "452")
        shot("02_speedtest")
    }

    func test03LAN() {
        tab("區網")
        app.buttons["lanButton"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["host-192.168.50.10"].waitForExistence(timeout: 30))
        XCTAssertTrue(any(containing: "Bonjour").waitForExistence(timeout: 10))
        shot("03_lan")
    }

    func test04ChannelCalculator() {
        tab("工具")
        app.buttons["tool-channel"].tap()
        let range = any(containing: "5945–6265 MHz")
        XCTAssertTrue(range.waitForExistence(timeout: 5), "default plan is 6 GHz ch37 320 MHz")
        shot("04_channel_calculator")
        app.segmentedControls["bandPicker"].buttons["5 GHz"].tap()
        let fiveRange = any(containing: "5170–5190 MHz")
        XCTAssertTrue(fiveRange.waitForExistence(timeout: 5))
        XCTAssertFalse(app.segmentedControls["widthPicker"].buttons["320 MHz"].exists, "320 MHz is not offered on 5 GHz")
        app.segmentedControls["bandPicker"].buttons["2.4 GHz"].tap()
        XCTAssertEqual(app.segmentedControls["widthPicker"].buttons.count, 2)
    }

    func test05SubnetCalculator() {
        tab("工具")
        app.buttons["tool-subnet"].tap()
        XCTAssertTrue(any(containing: "192.168.1.0/24").waitForExistence(timeout: 5))
        let field = app.textFields["subnetInput"]
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30))
        field.typeText("10.1.2.3 255.0.255.0")
        XCTAssertTrue(app.descendants(matching: .any)["subnetError"].waitForExistence(timeout: 5))
        shot("05_subnet_error")
    }

    func test06Tools() {
        tab("工具")
        app.buttons["tool-dns"].tap()
        app.buttons["dnsButton"].tap()
        XCTAssertTrue(any(containing: "17.253.144.10").waitForExistence(timeout: 5))
        shot("06_dns")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["tool-latency"].tap()
        app.buttons["latencyButton"].tap()
        XCTAssertTrue(any(containing: "10 / 10").waitForExistence(timeout: 20))
        shot("07_latency")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["tool-ports"].tap()
        app.buttons["portButton"].tap()
        XCTAssertTrue(any(containing: "開啟 3").waitForExistence(timeout: 20))
        XCTAssertFalse(any(containing: "3,389").exists)
        shot("08_ports")
    }

    func test07AboutAndRapidTabSwitching() {
        tab("關於")
        XCTAssertTrue(app.switches["demoToggle"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.switches["demoToggle"].value as? String, "1")
        shot("09_about")
        for _ in 0..<15 {
            for t in ["連線", "測速", "區網", "工具", "關於"] { tab(t) }
        }
        tab("測速")
        app.buttons["speedButton"].tap()
        app.buttons["speedButton"].tap()
        XCTAssertTrue(app.buttons["speedButton"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.state, .runningForeground)
    }
}
