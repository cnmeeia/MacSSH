import SwiftUI

/// Small labelled figure. `value` is a `Text` so callers can pass a FormatStyle.
struct Stat: View {
    let label: String
    let value: Text
    var color: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                if let color {
                    Circle().fill(color).frame(width: 8, height: 8).accessibilityHidden(true)
                }
                Text(label).font(.caption2.weight(.semibold)).foregroundStyle(Theme.label2)
            }
            value
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
