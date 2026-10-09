import SwiftUI
import MonitorCore

/// Single-column layout for iPhone.
struct NarrowDashboard: View {
    let s: Snapshot
    let model: DashboardModel

    var body: some View {
        GlassGroup {
            VStack(spacing: 14) {
                SystemCard(s: s).appear(0)
                HStack(spacing: 12) {
                    RateCard(title: "RX", value: s.totalRx, history: model.rxHistory, color: Theme.accent2)
                    RateCard(title: "TX", value: s.totalTx, history: model.txHistory, color: Theme.accent)
                }
                .appear(1)
                CPUCard(s: s).appear(2)
                MemoryCard(s: s).appear(3)
                NetworkCard(s: s).appear(4)
                DisksCard(s: s).appear(5)
            }
        }
    }
}
