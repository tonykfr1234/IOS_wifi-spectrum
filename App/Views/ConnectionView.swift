import SwiftUI
import UIKit
import WifiSpectrumCore

struct ConnectionView: View {
    @ObservedObject var model: ConnectionModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if model.services.isDemo { DemoBanner().clipShape(RoundedRectangle(cornerRadius: 8)).padding(.top, 8) }
                    content
                    SectionTitle("iOS 的限制")
                    Notice(text: "Apple 不允許 App 讀取附近的 Wi-Fi、頻道、頻寬、訊號強度與 Wi-Fi 7 MLO 資訊。需要這些功能請使用 Android 版「Wi-Fi 頻譜分析儀」。下方「工具 → 頻道計算機」可以手動查詢任何頻道與頻寬的佔用範圍。", color: Palette.accent)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .refreshable { await model.refresh() }
            .screenBackground()
            .navigationTitle("連線")
            .toolbar {
                Button { Task { await model.refresh() } } label: { Image(systemName: "arrow.clockwise") }
                    .accessibilityLabel("重新整理")
                    .accessibilityIdentifier("refreshConnection")
            }
            .task { await model.refresh() }
        }
    }

    @ViewBuilder private var content: some View {
        switch model.state {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(40)
        case .ready(let w):
            SectionTitle("目前的 Wi-Fi")
            Panel {
                VStack(alignment: .leading, spacing: 6) {
                    Text(w.ssid).font(.title2.weight(.semibold)).foregroundStyle(Palette.text)
                        .accessibilityIdentifier("ssid")
                    HStack(spacing: 6) {
                        if let raw = w.securityRaw {
                            Tag(text: WifiSecurity.label(rawValue: raw), color: WifiSecurity.isWeak(rawValue: raw) ? Palette.bad : Palette.good)
                        }
                        if let i = model.interface, i.supportsIPv6 { Tag(text: "IPv6", color: Palette.accent) }
                    }
                }
                .padding(14)
                Divider().overlay(Palette.line)
                KeyValueRow(label: "BSSID", value: w.bssid)
                KeyValueRow(label: "廠商", value: model.vendor ?? (model.randomizedBSSID ? "隨機／本地管理位址" : "未登錄"), mono: false)
            }
            interfacePanel
        case .needsPermission:
            SectionTitle("需要位置權限")
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("iOS 規定 App 必須取得位置權限，才能讀取目前連線的 Wi-Fi 名稱（SSID）與基地台位址（BSSID）。這個 App 不會讀取或儲存你的位置。")
                        .font(.subheadline).foregroundStyle(Palette.text2)
                    Button("允許位置權限") { Task { await model.requestPermission() } }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("grantLocation")
                }
                .padding(14)
            }
            interfacePanel
        case .denied:
            SectionTitle("位置權限已關閉")
            Panel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("沒有位置權限時，iOS 不提供 Wi-Fi 名稱與 BSSID。其他工具仍可使用。")
                        .font(.subheadline).foregroundStyle(Palette.text2)
                    Button("到設定開啟") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(14)
            }
            interfacePanel
        case .notConnected:
            SectionTitle("目前的 Wi-Fi")
            Notice(text: "沒有連上 Wi-Fi，或 iOS 沒有回報連線資訊。連上 Wi-Fi 後下拉重新整理。")
            interfacePanel
        }
    }

    @ViewBuilder private var interfacePanel: some View {
        if let i = model.interface {
            SectionTitle("網路介面")
            Panel {
                KeyValueRow(label: "IPv4 位址", value: i.ipv4 ?? "—")
                KeyValueRow(label: "子網路遮罩", value: i.netmask ?? "—")
                if let s = model.subnet {
                    KeyValueRow(label: "網段", value: "\(s.network)/\(s.prefix)（\(s.hostCount) 個位址）")
                }
                ForEach(i.ipv6, id: \.self) { KeyValueRow(label: "IPv6 位址", value: $0) }
                KeyValueRow(label: "連線類型", value: i.isWifi ? "Wi-Fi" : "非 Wi-Fi", mono: false)
                KeyValueRow(label: "數據節省", value: i.isConstrained ? "開啟（低數據模式）" : "關閉", mono: false)
                KeyValueRow(label: "計量網路", value: i.isExpensive ? "是（例如個人熱點）" : "否", mono: false)
            }
        }
    }
}
