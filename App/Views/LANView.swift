import SwiftUI
import WifiSpectrumCore

struct LANView: View {
    @ObservedObject var model: LANModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if model.services.isDemo { DemoBanner().clipShape(RoundedRectangle(cornerRadius: 8)).padding(.top, 8) }
                    Text("用 Bonjour 找出會自我介紹的裝置，並對同一網段的每個位址測試常用連接埠（\(Ports.sweep.map(String.init).joined(separator: "、"))）。iOS 不提供其他裝置的 MAC 位址，所以無法顯示廠商。")
                        .font(.footnote).foregroundStyle(Palette.text2).padding(.top, 12)

                    Button { model.scanning ? model.stop() : model.scan() } label: {
                        Text(model.scanning ? "停止掃描" : "開始掃描").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(model.scanning ? Palette.bad : Palette.accent)
                    .padding(.top, 12)
                    .accessibilityIdentifier("lanButton")

                    if model.scanning && model.total > 0 {
                        ProgressView(value: Double(model.progress), total: Double(model.total)) {
                            Text("已檢查 \(model.progress) / \(model.total) 個位址").font(.caption).foregroundStyle(Palette.text2)
                        }
                        .padding(.top, 12)
                    }
                    if let m = model.message { Notice(text: m).padding(.top, 12) }

                    if !model.hosts.isEmpty {
                        SectionTitle("有回應的主機 · \(model.hosts.count)" + (model.subnetText.map { " · \($0)" } ?? ""))
                        Panel {
                            ForEach(model.hosts) { h in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(h.address.description).font(.system(.body, design: .monospaced)).foregroundStyle(Palette.text)
                                    HStack(spacing: 6) {
                                        ForEach(h.openPorts, id: \.self) { Tag(text: "\($0) \(Ports.service($0))", color: Palette.accent) }
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier("host-\(h.address)")
                            }
                        }
                    }
                    if !model.bonjour.isEmpty {
                        SectionTitle("Bonjour 裝置 · \(model.bonjour.count)")
                        Panel {
                            ForEach(model.bonjour) { s in
                                HStack {
                                    Text(s.name).foregroundStyle(Palette.text)
                                    Spacer()
                                    Tag(text: s.type)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 9)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .navigationTitle("區域網路")
        }
    }
}
