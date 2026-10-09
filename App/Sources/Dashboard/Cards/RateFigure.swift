import SwiftUI

/// "12.3 MB/s" shown as a big figure with a small unit.
struct RateFigure: View {
    let text: String
    @ScaledMetric(relativeTo: .largeTitle) private var size = 42.0

    var body: some View {
        let parts = text.split(separator: " ", maxSplits: 1)
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(String(parts.first ?? ""))
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(String(parts.dropFirst().first ?? "")).font(.headline).foregroundStyle(Theme.label2)
        }
        .accessibilityElement(children: .combine)
    }
}
