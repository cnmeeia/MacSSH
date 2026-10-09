import SwiftUI

struct CoreCell: View {
    let index: Int
    let usage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("CPU \(index)").font(.caption).foregroundStyle(Theme.label2)
                Spacer()
                Text(percent: usage, digits: 0)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .contentTransition(.numericText(value: usage))
            }
            Bar(fraction: usage / 100, color: usage > 80 ? Theme.orange : Theme.accent, height: 5)
        }
        .accessibilityElement(children: .combine)
    }
}
