import SwiftUI
import MonitorCore

/// Two-column layout for Mac and iPad.
struct WideDashboard: View {
    let s: Snapshot
    let model: DashboardModel

    var body: some View {
        GlassGroup {
            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 16) {
                    SystemCard(s: s).appear(0)
                    CPUCard(s: s).appear(1)
                    MemoryCard(s: s).appear(2)
                    DisksCard(s: s).appear(3)
                }
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        RateCard(title: "接收 · RX", value: s.totalRx, history: model.rxHistory, color: Theme.accent2).appear(1)
                        RateCard(title: "发送 · TX", value: s.totalTx, history: model.txHistory, color: Theme.accent).appear(2)
                    }
                    NetworkCard(s: s).appear(3)
                }
            }
        }
    }
}
