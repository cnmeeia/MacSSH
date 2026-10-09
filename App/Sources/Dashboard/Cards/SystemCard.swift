import SwiftUI
import MonitorCore

struct SystemCard: View {
    let s: Snapshot

    var body: some View {
        Card("系统负载") {
            BigNumber(value: s.load1, fractionDigits: 2, unit: "1 分钟")
            HStack {
                Stat(label: "5 分钟", value: Text(s.load5, format: .number.precision(.fractionLength(2))))
                Stat(label: "15 分钟", value: Text(s.load15, format: .number.precision(.fractionLength(2))))
                Stat(label: "进程", value: Text(verbatim: "\(s.runningProcs) / \(s.totalProcs)"))
            }
        } trailing: {
            PulseDot(color: isOverloaded ? Theme.orange : Theme.green)
        }
    }

    /// Load above the core count means work is queueing.
    private var isOverloaded: Bool { s.load1 > Double(max(1, s.host.cores)) }
}
