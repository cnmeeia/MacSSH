import SwiftUI
import MonitorCore

struct DiskRow: View {
    let disk: DiskMount

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(disk.mount).font(.system(.subheadline, design: .monospaced)).lineLimit(1).truncationMode(.middle)
                Spacer()
                if disk.usedPercent > 90 {
                    // Not colour alone: a symbol marks a nearly full disk.
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red).accessibilityLabel("空间不足")
                }
                Text(percent: disk.usedPercent, digits: 0).fontWeight(.semibold)
                Text("\(Format.kb(disk.usedKB)) / \(Format.kb(disk.sizeKB))").foregroundStyle(Theme.label2)
            }
            .font(.subheadline)
            Bar(fraction: disk.usedPercent / 100, color: color, height: 6)
        }
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        disk.usedPercent > 90 ? .red : (disk.usedPercent > 75 ? Theme.orange : Theme.accent)
    }
}
