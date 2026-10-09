import SwiftUI
import MonitorCore

struct SwapView: View {
    let memory: MemoryInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BigNumber(value: percent, unit: "%")
            Bar(fraction: percent / 100, color: Theme.purple)
            Text("已用 \(Format.kb(memory.swapUsedKB)) / 共 \(Format.kb(memory.swapTotalKB))")
                .font(.footnote).foregroundStyle(Theme.label2)
        }
    }

    private var percent: Double {
        memory.swapTotalKB == 0 ? 0 : Double(memory.swapUsedKB) / Double(memory.swapTotalKB) * 100
    }
}
