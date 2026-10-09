import SwiftUI

struct LegendItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8).accessibilityHidden(true)
            Text(label).foregroundStyle(Theme.label2)
            Text(value).fontWeight(.semibold).contentTransition(.numericText())
        }
        .font(.subheadline)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .accessibilityElement(children: .combine)
    }
}
