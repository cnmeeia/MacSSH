import SwiftUI
import MonitorCore

struct CPUOverview: View {
    let cpu: CPUUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BigNumber(value: cpu.total, unit: "%")
            Bar(fraction: cpu.total / 100, color: Theme.accent)
            HStack {
                Stat(label: "用户", value: Text(percent: cpu.user), color: Theme.accent)
                Stat(label: "系统", value: Text(percent: cpu.system), color: Theme.accent2)
                Stat(label: "IO 等待", value: Text(percent: cpu.iowait), color: Theme.orange)
                Stat(label: "Nice", value: Text(percent: cpu.nice), color: .gray)
            }
        }
    }
}
