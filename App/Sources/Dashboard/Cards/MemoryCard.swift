import SwiftUI
import MonitorCore

struct MemoryCard: View {
    let s: Snapshot
    @State private var showSwap = false

    var body: some View {
        Card("内存 · \(Format.kb(s.memory.totalKB))") {
            VStack(alignment: .leading) {
                if showSwap {
                    SwapView(memory: s.memory)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    RAMView(memory: s.memory)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        } trailing: {
            SegmentToggle(title: "内存视图", right: $showSwap, left: "RAM", rightLabel: "Swap")
        }
    }
}
