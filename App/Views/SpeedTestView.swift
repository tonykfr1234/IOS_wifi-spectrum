import SwiftUI
import WifiSpectrumCore

struct SpeedGauge: View {
    var mbps: Double
    var color: Color
    private static let stops: [Double] = [0, 10, 50, 100, 250, 500, 1000]

    static func fraction(_ v: Double) -> Double {
        for i in 1..<stops.count where v <= stops[i] {
            return (Double(i - 1) + (v - stops[i - 1]) / (stops[i] - stops[i - 1])) / Double(stops.count - 1)
        }
        return 1
    }

    var body: some View {
        ZStack {
            Circle().trim(from: 0, to: 0.75).stroke(Palette.line, style: StrokeStyle(lineWidth: 14, lineCap: .round)).rotationEffect(.degrees(135))
            Circle().trim(from: 0, to: 0.75 * Self.fraction(max(0, mbps))).stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round)).rotationEffect(.degrees(135))
            VStack(spacing: 2) {
                Text(Throughput.format(mbps))
                    .font(.system(size: 52, weight: .light, design: .monospaced))
                    .foregroundStyle(Palette.text)
                    .accessibilityIdentifier("gaugeValue")
                Text("Mbps").font(.footnote).foregroundStyle(Palette.text2)
            }
        }
        .frame(width: 240, height: 240)
    }
}

struct SpeedTestView: View {
    @ObservedObject var model: SpeedTestModel

    private var caption: String {
        switch model.phase {
        case .idle: return "點「開始測速」"
        case .latency: return "正在測量延遲…"
        case .download: return "下載中"
        case .upload: return "上傳中"
        case .done: return "完成 · 下載速度"
        case .failed: return "測速失敗"
        case .cancelled: return "已取消"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if model.services.isDemo { DemoBanner().clipShape(RoundedRectangle(cornerRadius: 8)).padding(.top, 8) }
                    Panel {
                        VStack(spacing: 8) {
                            SpeedGauge(mbps: model.phase == .done ? (model.result?.downloadMbps ?? 0) : model.live,
                                       color: model.phase == .upload ? Palette.good : Palette.accent)
                            Text(caption).font(.subheadline).foregroundStyle(Palette.text2).accessibilityIdentifier("speedPhase")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    .padding(.top, 12)

                    HStack(spacing: 0) {
                        metric("下載", model.result.map { Throughput.format($0.downloadMbps) }, "Mbps", Palette.accent)
                        metric("上傳", model.result.map { Throughput.format($0.uploadMbps) }, "Mbps", Palette.good)
                        metric("延遲", model.result?.latency.map { String(format: "%.0f", $0.medianMs) }, "ms", Palette.warn)
                        metric("抖動", model.result?.latency.map { String(format: "%.1f", $0.jitterMs) }, "ms", Palette.text2)
                    }
                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 12)

                    Button {
                        model.isRunning ? model.cancel() : model.start()
                    } label: {
                        Text(model.isRunning ? "停止" : (model.result == nil ? "開始測速" : "再測一次"))
                            .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(model.isRunning ? Palette.bad : Palette.accent)
                    .padding(.top, 14)
                    .accessibilityIdentifier("speedButton")

                    if let e = model.error { Notice(text: e, color: Palette.bad).padding(.top, 12) }

                    if !model.history.isEmpty {
                        SectionTitle("測速紀錄")
                        Panel {
                            ForEach(Array(model.history.enumerated()), id: \.offset) { _, r in
                                HStack {
                                    Text(r.date, style: .time).font(.system(.footnote, design: .monospaced)).foregroundStyle(Palette.text2)
                                    Spacer()
                                    Text("↓ \(Throughput.format(r.downloadMbps))").foregroundStyle(Palette.accent)
                                    Text("↑ \(Throughput.format(r.uploadMbps))").foregroundStyle(Palette.good)
                                    Text("Mbps").font(.caption).foregroundStyle(Palette.text2)
                                }
                                .font(.system(.subheadline, design: .monospaced))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                            }
                        }
                    }
                    SectionTitle("測速方式")
                    Text("連線到 Cloudflare 公開測速伺服器（speed.cloudflare.com），下載與上傳各 3 次取中位數；延遲為 10 次 HTTPS 往返的中位數。測速會使用約 100 MB 流量，使用行動網路時請留意。")
                        .font(.footnote).foregroundStyle(Palette.text2).padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .navigationTitle("測速")
        }
    }

    private func metric(_ label: String, _ value: String?, _ unit: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(label).font(.caption).foregroundStyle(Palette.text2)
            }
            Text(value ?? "—").font(.system(.title3, design: .monospaced)).foregroundStyle(Palette.text)
            Text(unit).font(.caption2).foregroundStyle(Palette.text2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("metric-\(label)")
    }
}
