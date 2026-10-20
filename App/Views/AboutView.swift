import SwiftUI

struct AboutView: View {
    @Binding var demoMode: Bool
    var isDemo: Bool
    /// True when the demo was forced by a launch argument, so the switch cannot turn it off.
    var locked = false

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v)（\(b)）"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("示範模式", isOn: $demoMode).disabled(locked).accessibilityIdentifier("demoToggle")
                } footer: {
                    Text(isDemo ? "目前顯示模擬資料：一間有 Wi-Fi 7 路由器的台北公寓。" : "沒有 Wi-Fi 或想先看介面時，可以開啟示範模式。")
                }
                Section("iOS 版能做與不能做的事") {
                    Text("能做：目前連線的 SSID、BSSID 與廠商、IP 與網段、測速、區域網路裝置探索、TCP 延遲、DNS、連接埠掃描、頻道與子網路計算。")
                    Text("不能做：附近 Wi-Fi 清單、頻道、頻寬、訊號強度與 Wi-Fi 7 MLO。Apple 沒有開放這些資訊給 App，請使用 Android 版。")
                }
                .font(.footnote)
                Section("隱私") {
                    Text("App 不收集、不儲存、不上傳任何個人資料，也沒有廣告與分析工具。位置權限只用來讓 iOS 提供目前連線的 Wi-Fi 名稱；區域網路權限只用來尋找同一網段的裝置。測速時會連線到 Cloudflare 測速伺服器，只傳送測試用的資料。")
                        .font(.footnote)
                    Link("Android 版（GitHub）", destination: URL(string: "https://github.com/tonykfr1234/android_wifi-spectrum")!)
                    Link("iOS 版原始碼與隱私權政策", destination: URL(string: "https://github.com/tonykfr1234/ios_wifi-spectrum")!)
                }
                Section("資料來源") {
                    Text("廠商名稱：IEEE Registration Authority MA-L 公開登錄表（內建於 App）。").font(.footnote)
                }
                Section { KeyValueRow(label: "版本", value: version) }
            }
            .screenBackground()
            .navigationTitle("關於")
        }
    }
}
