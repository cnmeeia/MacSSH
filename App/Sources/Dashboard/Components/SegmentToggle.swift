import SwiftUI

struct SegmentToggle: View {
    let title: String
    @Binding var right: Bool
    let left: String
    let rightLabel: String

    var body: some View {
        Picker(title, selection: $right.animation(Theme.spring)) {
            Text(left).tag(false)
            Text(rightLabel).tag(true)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .fixedSize()
    }
}
