import SwiftUI

/// Large rounded figure + unit. Scales with Dynamic Type.
struct BigNumber: View {
    let value: Double
    var fractionDigits = 1
    let unit: String
    @ScaledMetric(relativeTo: .largeTitle) private var size = 42.0

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value, format: .number.precision(.fractionLength(fractionDigits)))
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: value))
            Text(unit).font(.headline).foregroundStyle(Theme.label2)
        }
    }
}
