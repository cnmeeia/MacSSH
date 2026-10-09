import SwiftUI
import MonitorCore

struct DashboardHeader: View {
    let server: ServerProfile
    let model: DashboardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                PulseDot(color: statusColor)
                Text(statusText).font(.caption.weight(.semibold)).foregroundStyle(Theme.label2)
                    .contentTransition(.opacity)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .glassCard(radius: 14)
            .animation(.easeInOut, value: statusText)

            Text(server.displayName).font(.largeTitle.bold())

            if let s = model.snapshot {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), alignment: .leading)], alignment: .leading, spacing: 12) {
                    InfoItem(label: "主机名", value: s.host.hostname)
                    InfoItem(label: "系统", value: s.host.os)
                    InfoItem(label: "运行时间", value: Format.uptime(s.uptimeSeconds))
                    InfoItem(label: "地址", value: server.host)
                }
                .transition(.opacity)
            }
        }
    }

    private var statusColor: Color {
        model.error == nil && model.snapshot != nil ? Theme.green : Theme.orange
    }

    private var statusText: String {
        if model.error != nil { return "重连中…" }
        if model.snapshot == nil { return "连接中…" }
        if let ms = model.connectMillis { return "每 \(model.interval.components.seconds) 秒刷新 · 首屏 \(ms) ms" }
        return "每 \(model.interval.components.seconds) 秒刷新"
    }
}
