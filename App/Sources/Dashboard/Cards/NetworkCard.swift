import SwiftUI
import MonitorCore

struct NetworkCard: View {
    let s: Snapshot
    @State private var showAll = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let peak = max(1, s.interfaces.map { max($0.rxPerSec, $0.txPerSec) }.max() ?? 1)
        Card("网卡 · 每秒") {
            ForEach(visible) { interface in
                InterfaceRow(interface: interface, peak: peak)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
            if s.interfaces.count > 6 {
                Button(showAll ? "收起" : "显示全部 \(s.interfaces.count) 个", action: toggleAll)
                    .font(.footnote.weight(.semibold))
                    .buttonStyle(.borderless)
            }
        } trailing: {
            Text("↓ \(Format.bytesPerSec(s.totalRx))  ↑ \(Format.bytesPerSec(s.totalTx))")
                .font(.caption2.monospacedDigit()).foregroundStyle(Theme.label2)
        }
    }

    private var visible: [InterfaceRate] { showAll ? s.interfaces : Array(s.interfaces.prefix(6)) }

    private func toggleAll() {
        withAnimation(Theme.spring) { showAll.toggle() }
    }
}
