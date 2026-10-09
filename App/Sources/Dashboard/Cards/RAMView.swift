import SwiftUI
import MonitorCore

struct RAMView: View {
    let memory: MemoryInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BigNumber(value: memory.usedPercent, unit: "%")
            MemoryStackBar(memory: memory)
            HStack(spacing: 14) {
                LegendItem(label: "已用", value: Format.kb(memory.usedKB), color: Theme.accent)
                LegendItem(label: "缓存", value: Format.kb(memory.cacheKB), color: Theme.accent2)
                LegendItem(label: "空闲", value: Format.kb(memory.freeKB), color: Theme.track)
            }
        }
    }
}
