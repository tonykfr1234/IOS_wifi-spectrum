import SwiftUI
import UIKit
import WifiSpectrumCore

enum AppEnvironment {
    /// Loaded once; the registry is 40k entries.
    static let vendors = VendorDatabase.bundled()
    static var arguments: [String] { ProcessInfo.processInfo.arguments }
    static var forcedDemo: Bool { arguments.contains("-demo") }
    static var uiTesting: Bool { arguments.contains("-uiTesting") }
}

extension Services {
    static func live(vendors: VendorDatabase) -> Services {
        Services(wifi: SystemWifiInfo(), speed: CloudflareSpeedTest(), latency: TCPLatencyProbe(),
                 lan: SystemLANScanner(), dns: SystemDNSResolver(), vendors: vendors, isDemo: false)
    }

    static func demo(vendors: VendorDatabase, fast: Bool) -> Services {
        Services(wifi: DemoWifiInfo(), speed: DemoSpeedTest(stepDelay: fast ? 1_000_000 : 120_000_000),
                 latency: DemoLatencyProbe(), lan: DemoLANScanner(stepDelay: fast ? 0 : 8_000_000),
                 dns: DemoDNSResolver(), vendors: vendors, isDemo: true)
    }
}

@main
struct WifiSpectrumApp: App {
    init() {
        if AppEnvironment.uiTesting { UIView.setAnimationsEnabled(false) }
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(Palette.surface)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }

    var body: some Scene {
        WindowGroup {
            AppRoot().preferredColorScheme(.dark).tint(Palette.accent)
        }
    }
}

struct AppRoot: View {
    @AppStorage("demoMode") private var demoMode = false
    @State private var live = Services.live(vendors: AppEnvironment.vendors)
    @State private var demo = Services.demo(vendors: AppEnvironment.vendors, fast: AppEnvironment.uiTesting)

    private var useDemo: Bool { demoMode || AppEnvironment.forcedDemo }

    var body: some View {
        MainTabs(services: useDemo ? demo : live, demoMode: $demoMode)
            .id(useDemo)
    }
}

struct MainTabs: View {
    @StateObject private var connection: ConnectionModel
    @StateObject private var speed: SpeedTestModel
    @StateObject private var lan: LANModel
    private let services: Services
    @Binding var demoMode: Bool

    init(services: Services, demoMode: Binding<Bool>) {
        self.services = services
        _demoMode = demoMode
        _connection = StateObject(wrappedValue: ConnectionModel(services: services))
        _speed = StateObject(wrappedValue: SpeedTestModel(services: services))
        _lan = StateObject(wrappedValue: LANModel(services: services))
    }

    var body: some View {
        TabView {
            ConnectionView(model: connection)
                .tabItem { Label("連線", systemImage: "wifi") }
            SpeedTestView(model: speed)
                .tabItem { Label("測速", systemImage: "speedometer") }
            LANView(model: lan)
                .tabItem { Label("區網", systemImage: "network") }
            ToolsView(services: services)
                .tabItem { Label("工具", systemImage: "wrench.and.screwdriver") }
            AboutView(demoMode: Binding(get: { demoMode || AppEnvironment.forcedDemo }, set: { demoMode = $0 }),
                      isDemo: services.isDemo, locked: AppEnvironment.forcedDemo)
                .tabItem { Label("關於", systemImage: "info.circle") }
        }
    }
}

struct DemoBanner: View {
    var body: some View {
        Text("示範模式：畫面上的資料是模擬的")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Palette.warn)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Palette.warn.opacity(0.12))
            .accessibilityIdentifier("demoBanner")
    }
}
