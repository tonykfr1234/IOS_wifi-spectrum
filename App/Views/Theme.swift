import SwiftUI

/// Same instrument-panel palette as the Android app.
enum Palette {
    static let bg = Color(red: 0x0B / 255, green: 0x0F / 255, blue: 0x14 / 255)
    static let surface = Color(red: 0x12 / 255, green: 0x18 / 255, blue: 0x20 / 255)
    static let surface2 = Color(red: 0x1A / 255, green: 0x22 / 255, blue: 0x2C / 255)
    static let line = Color(red: 0x26 / 255, green: 0x31 / 255, blue: 0x40 / 255)
    static let text = Color(red: 0xE6 / 255, green: 0xED / 255, blue: 0xF3 / 255)
    static let text2 = Color(red: 0x8B / 255, green: 0x98 / 255, blue: 0xA8 / 255)
    static let accent = Color(red: 0x2B / 255, green: 0xC4 / 255, blue: 0xFF / 255)
    static let good = Color(red: 0x3C / 255, green: 0xE3 / 255, blue: 0x8A / 255)
    static let warn = Color(red: 0xFF / 255, green: 0xB0 / 255, blue: 0x20 / 255)
    static let bad = Color(red: 0xFF / 255, green: 0x5A / 255, blue: 0x5A / 255)
    static let wifi7 = Color(red: 0xC0 / 255, green: 0x8B / 255, blue: 0xFF / 255)
}

struct Panel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.line, lineWidth: 1))
    }
}

struct SectionTitle: View {
    var text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Palette.text2)
            .padding(.top, 18)
            .padding(.bottom, 6)
            .padding(.horizontal, 4)
    }
}

struct KeyValueRow: View {
    var label: String
    var value: String
    var mono = true
    var valueColor = Palette.text

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label).foregroundStyle(Palette.text2).frame(width: 104, alignment: .leading)
            Text(value)
                .font(mono ? .system(.subheadline, design: .monospaced) : .subheadline)
                .foregroundStyle(valueColor)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
    }
}

struct Tag: View {
    var text: String
    var color: Color = Palette.text2

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color.opacity(0.5), lineWidth: 1))
    }
}

struct Notice: View {
    var text: String
    var color: Color = Palette.warn

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Palette.text)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.5), lineWidth: 1))
    }
}

extension View {
    func screenBackground() -> some View {
        scrollContentBackground(.hidden).background(Palette.bg.ignoresSafeArea())
    }
}
