import SwiftUI
import WifiSpectrumCore

struct ToolsView: View {
    let services: Services

    var body: some View {
        NavigationStack {
            List {
                Section("計算") {
                    NavigationLink { ChannelCalculatorView() } label: { row("頻道計算機", "頻段、頻道、頻寬 → 佔用範圍與涵蓋頻道", "chart.bar.xaxis", Palette.wifi7) }
                        .accessibilityIdentifier("tool-channel")
                    NavigationLink { SubnetCalculatorView() } label: { row("子網路計算機", "IP／遮罩 → 網段、廣播位址、可用主機", "square.grid.3x3", Palette.accent) }
                        .accessibilityIdentifier("tool-subnet")
                }
                Section("診斷") {
                    NavigationLink { LatencyView(model: LatencyModel(services: services)) } label: { row("TCP 延遲", "連線建立時間，取代 iOS 不允許的 ICMP Ping", "waveform.path.ecg", Palette.good) }
                        .accessibilityIdentifier("tool-latency")
                    NavigationLink { DNSView(model: DNSModel(services: services)) } label: { row("DNS 查詢", "A、AAAA 與正式名稱", "globe", Palette.accent) }
                        .accessibilityIdentifier("tool-dns")
                    NavigationLink { PortScanView(model: PortScanModel(services: services)) } label: { row("連接埠掃描", "常用 19 個或自訂範圍", "door.left.hand.open", Palette.warn) }
                        .accessibilityIdentifier("tool-ports")
                }
            }
            .listStyle(.insetGrouped)
            .screenBackground()
            .navigationTitle("工具")
        }
    }

    private func row(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.white).frame(width: 30, height: 30).background(color, in: RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundStyle(Palette.text)
                Text(subtitle).font(.caption).foregroundStyle(Palette.text2)
            }
        }
        .padding(.vertical, 2)
    }
}

struct ChannelCalculatorView: View {
    @State private var band: Band = .ghz6
    @State private var channel = 37
    @State private var width: ChannelWidth = .mhz320

    private var plan: ChannelPlan? { ChannelPlan(band: band, channel: channel, width: width) }

    var body: some View {
        Form {
            Section {
                Picker("頻段", selection: $band) { ForEach(Band.allCases) { Text($0.label).tag($0) } }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("bandPicker")
                Picker("主頻道", selection: $channel) {
                    ForEach(Channels.candidateChannels(band), id: \.self) { ch in
                        Text(band == .ghz6 && Channels.isPreferredScanningChannel(ch) ? "\(ch)（PSC）" : "\(ch)").tag(ch)
                    }
                }
                .accessibilityIdentifier("channelPicker")
                Picker("頻寬", selection: $width) { ForEach(ChannelWidth.allowed(in: band)) { Text($0.label).tag($0) } }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("widthPicker")
            }
            if let p = plan {
                Section {
                    BandStrip(plan: p).frame(height: 54).listRowBackground(Palette.surface)
                }
                Section("結果") {
                    KeyValueRow(label: "主頻道頻率", value: "\(p.primaryFrequency) MHz")
                    KeyValueRow(label: "中心頻道", value: "\(p.centerChannel)（\(p.centerFrequency) MHz）")
                    KeyValueRow(label: "佔用範圍", value: "\(p.lowMHz)–\(p.highMHz) MHz")
                        .accessibilityIdentifier("planRange")
                    KeyValueRow(label: "涵蓋頻道", value: p.coveredChannels.map(String.init).joined(separator: ", "))
                    if let u = p.unii { KeyValueRow(label: "子頻段", value: u) }
                    if band == .ghz6 { KeyValueRow(label: "PSC 頻道", value: p.isPSC ? "是，手機會優先掃描" : "否", mono: false) }
                    if band == .ghz5 { KeyValueRow(label: "DFS", value: p.hasDFS ? "包含 DFS 頻道，偵測到雷達時須換頻道" : "不含", mono: false, valueColor: p.hasDFS ? Palette.warn : Palette.text) }
                    if band == .ghz2_4 && width == .mhz40 { KeyValueRow(label: "提醒", value: "2.4 GHz 用 40 MHz 會佔掉三分之二的頻段，鄰居多時建議 20 MHz", mono: false, valueColor: Palette.warn) }
                }
            }
        }
        .screenBackground()
        .navigationTitle("頻道計算機")
        .onChange(of: band) { b in
            if !Channels.candidateChannels(b).contains(channel) { channel = Channels.candidateChannels(b).first ?? 1 }
            if !ChannelWidth.allowed(in: b).contains(width) { width = .mhz20 }
        }
    }
}

/// The whole band with the selected block highlighted.
struct BandStrip: View {
    let plan: ChannelPlan

    var body: some View {
        Canvas { ctx, size in
            let chans = Channels.candidateChannels(plan.band)
            let lo = Double(Channels.frequency(band: plan.band, channel: chans.first!) - 10)
            let hi = Double(Channels.frequency(band: plan.band, channel: chans.last!) + 10)
            func x(_ f: Int) -> CGFloat { CGFloat((Double(f) - lo) / (hi - lo)) * size.width }
            ctx.fill(Path(CGRect(x: 0, y: size.height - 6, width: size.width, height: 2)), with: .color(Palette.line))
            for ch in chans {
                let cx = x(Channels.frequency(band: plan.band, channel: ch))
                ctx.fill(Path(CGRect(x: cx, y: size.height - 10, width: 1, height: 8)), with: .color(Palette.line))
            }
            let rect = CGRect(x: x(plan.lowMHz), y: 8, width: max(2, x(plan.highMHz) - x(plan.lowMHz)), height: size.height - 18)
            ctx.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Palette.wifi7.opacity(0.35)))
            ctx.stroke(Path(roundedRect: rect, cornerRadius: 4), with: .color(Palette.wifi7), lineWidth: 1.5)
            let px = x(plan.primaryFrequency)
            ctx.fill(Path(CGRect(x: px - 1, y: 4, width: 2, height: size.height - 10)), with: .color(Palette.accent))
        }
        .accessibilityLabel("\(plan.band.label) 頻段中 \(plan.lowMHz) 到 \(plan.highMHz) MHz 的位置")
    }
}

struct SubnetCalculatorView: View {
    @State private var input = "192.168.1.105/24"

    private var result: Result<Subnet, SubnetError> {
        do { return .success(try Subnet(parsing: input)) } catch let e as SubnetError { return .failure(e) } catch { return .failure(.badAddress) }
    }

    var body: some View {
        Form {
            Section {
                TextField("192.168.1.10/24 或 192.168.1.10 255.255.255.0", text: $input)
                    .font(.system(.body, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.numbersAndPunctuation)
                    .accessibilityIdentifier("subnetInput")
            }
            switch result {
            case .success(let s):
                Section("結果") {
                    KeyValueRow(label: "網路位址", value: "\(s.network)/\(s.prefix)").accessibilityIdentifier("subnetNetwork")
                    KeyValueRow(label: "子網路遮罩", value: s.mask.description)
                    KeyValueRow(label: "廣播位址", value: s.broadcast.description)
                    KeyValueRow(label: "可用主機", value: "\(s.firstHost) – \(s.lastHost)")
                    KeyValueRow(label: "主機數量", value: "\(s.hostCount)")
                    KeyValueRow(label: "私有網段", value: s.address.isPrivate ? "是" : "否", mono: false)
                }
            case .failure(let e):
                Section {
                    Text(message(e)).foregroundStyle(Palette.bad).accessibilityIdentifier("subnetError")
                }
            }
        }
        .screenBackground()
        .navigationTitle("子網路計算機")
    }

    private func message(_ e: SubnetError) -> String {
        switch e {
        case .badAddress: return "IP 位址格式不正確，例如 192.168.1.10。"
        case .badPrefix: return "請加上前綴長度（/24）或子網路遮罩（255.255.255.0），前綴是 0–32。"
        case .nonContiguousMask: return "子網路遮罩的 1 必須連續，例如 255.255.255.0。"
        }
    }
}

struct LatencyView: View {
    @StateObject var model: LatencyModel

    var body: some View {
        Form {
            Section {
                TextField("主機", text: $model.host).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                    .accessibilityIdentifier("latencyHost")
                TextField("連接埠", text: $model.portText).keyboardType(.numberPad)
                Button(model.running ? "停止" : "開始量測") { model.running ? model.stop() : model.start() }
                    .accessibilityIdentifier("latencyButton")
            } footer: {
                Text("iOS 不允許一般 App 送出 ICMP Ping，這裡量的是 TCP 連線建立時間，會比 Ping 略高。")
            }
            if let e = model.error { Section { Text(e).foregroundStyle(Palette.bad) } }
            if let s = model.stats {
                Section("統計") {
                    KeyValueRow(label: "成功 / 送出", value: "\(s.received) / \(s.sent)")
                    KeyValueRow(label: "遺失率", value: String(format: "%.0f%%", s.lossPercent), valueColor: s.lossPercent > 0 ? Palette.warn : Palette.good)
                    KeyValueRow(label: "最短 / 中位 / 最長", value: String(format: "%.1f / %.1f / %.1f ms", s.minMs, s.medianMs, s.maxMs))
                        .accessibilityIdentifier("latencyStats")
                    KeyValueRow(label: "抖動", value: String(format: "%.1f ms", s.jitterMs))
                }
            }
            if !model.samples.isEmpty {
                Section("每次結果") {
                    ForEach(Array(model.samples.enumerated()), id: \.offset) { i, v in
                        KeyValueRow(label: "#\(i + 1)", value: v.map { String(format: "%.1f ms", $0) } ?? "逾時", valueColor: v == nil ? Palette.bad : Palette.text)
                    }
                }
            }
        }
        .screenBackground()
        .navigationTitle("TCP 延遲")
        .onDisappear { model.stop() }
    }
}

struct DNSView: View {
    @StateObject var model: DNSModel

    var body: some View {
        Form {
            Section {
                TextField("網域名稱", text: $model.host).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                    .onSubmit { Task { await model.lookup() } }
                    .accessibilityIdentifier("dnsHost")
                Button("查詢") { Task { await model.lookup() } }.disabled(model.running).accessibilityIdentifier("dnsButton")
            } footer: {
                Text("使用系統設定的 DNS 伺服器。")
            }
            if let e = model.error { Section { Text(e).foregroundStyle(Palette.bad).accessibilityIdentifier("dnsError") } }
            if let a = model.answer {
                Section("結果") {
                    if let c = a.canonicalName { KeyValueRow(label: "正式名稱", value: c) }
                    ForEach(a.ipv4, id: \.self) { KeyValueRow(label: "A", value: $0).accessibilityIdentifier("dnsA") }
                    ForEach(a.ipv6, id: \.self) { KeyValueRow(label: "AAAA", value: $0) }
                    KeyValueRow(label: "查詢時間", value: String(format: "%.0f ms", a.milliseconds))
                }
            }
        }
        .screenBackground()
        .navigationTitle("DNS 查詢")
    }
}

struct PortScanView: View {
    @StateObject var model: PortScanModel

    var body: some View {
        Form {
            Section {
                TextField("主機", text: $model.host).textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                    .accessibilityIdentifier("portHost")
                TextField("連接埠（留空＝常用 19 個）", text: $model.portsText).keyboardType(.numbersAndPunctuation)
                    .accessibilityIdentifier("portList")
                Button(model.running ? "停止" : "開始掃描") { model.running ? model.stop() : model.start() }
                    .accessibilityIdentifier("portButton")
            }
            if let e = model.error { Section { Text(e).foregroundStyle(Palette.bad).accessibilityIdentifier("portError") } }
            if model.running { Section { ProgressView(value: Double(model.done), total: Double(max(model.total, 1))) } }
            if !model.rows.isEmpty {
                Section("開啟 \(model.openRows.count) · 未回應 \(model.rows.count - model.openRows.count)") {
                    ForEach(model.openRows) { r in
                        HStack {
                            Text(verbatim: String(r.port)).font(.system(.body, design: .monospaced))
                            Text(Ports.service(r.port)).foregroundStyle(Palette.text2)
                            Spacer()
                            Tag(text: "開啟", color: Palette.good)
                        }
                    }
                    if model.openRows.isEmpty { Text("沒有開啟的連接埠").foregroundStyle(Palette.text2) }
                }
            }
        }
        .screenBackground()
        .navigationTitle("連接埠掃描")
        .onDisappear { model.stop() }
    }
}
