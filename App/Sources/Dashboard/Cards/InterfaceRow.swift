import SwiftUI
import MonitorCore

struct InterfaceRow: View {
    let interface: InterfaceRate
    let peak: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(interface.name).font(.system(.subheadline, design: .monospaced)).lineLimit(1)
                Spacer()
                Text("↓ \(Format.bytesPerSec(interface.rxPerSec))").fontWeight(.semibold).contentTransition(.numericText())
                Text("↑ \(Format.bytesPerSec(interface.txPerSec))").foregroundStyle(Theme.label2).contentTransition(.numericText())
            }
            .font(.subheadline.monospacedDigit())
            HStack(spacing: 4) {
                Bar(fraction: interface.rxPerSec / peak, color: Theme.accent2, height: 5)
                Bar(fraction: interface.txPerSec / peak, color: Theme.accent, height: 5)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
