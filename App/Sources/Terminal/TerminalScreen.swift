import SwiftUI

struct TerminalScreen: View {
    let bridge: TerminalBridge
    let isActive: Bool

    var body: some View {
        TerminalHost(bridge: bridge, isActive: isActive)
            .padding(12)
            .background(Color.white.opacity(0.92), in: .rect(cornerRadius: 20, style: .continuous))
            .glassCard(radius: 20)
            .padding(14)
            .overlay(alignment: .topTrailing) {
                if bridge.closedReason != nil {
                    Button("重新连接", systemImage: "arrow.clockwise", action: reconnect)
                        .prominentGlassButton()
                        .padding(26)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(Theme.spring, value: bridge.closedReason)
            .task {
                await Task.yield()          // let the view get its real size first
                bridge.startIfNeeded()
            }
    }

    private func reconnect() { bridge.reconnect() }
}
