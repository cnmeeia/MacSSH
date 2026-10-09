import SwiftUI
import MonitorCore

/// Used / cache / free as one segmented bar.
struct MemoryStackBar: View {
    let memory: MemoryInfo

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.accent)
                    .frame(width: max(0, proxy.size.width * usedFraction - 3))
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.accent2.opacity(0.8))
                    .frame(width: max(0, proxy.size.width * cacheFraction - 3))
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.track)
            }
            .animation(Theme.spring, value: memory.usedKB)
        }
        .frame(height: 22)
        .accessibilityHidden(true)
    }

    private var total: Double { max(1, Double(memory.totalKB)) }
    private var usedFraction: Double { Double(memory.usedKB) / total }
    private var cacheFraction: Double {
        Double(min(memory.cacheKB, memory.totalKB - min(memory.usedKB, memory.totalKB))) / total
    }
}
