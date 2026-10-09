import SwiftUI

/// Monitor and terminal share one session; both stay alive while you flip between them.
struct ServerDetailView: View {
    let server: ServerProfile
    let session: ServerSession
    @State private var tab: DetailTab = .monitor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            AppBackground()
            DashboardView(server: server, model: session.dashboard)
                .opacity(tab == .monitor ? 1 : 0)
                .scaleEffect(tab == .monitor || reduceMotion ? 1 : 0.98)
                .allowsHitTesting(tab == .monitor)
                .accessibilityHidden(tab != .monitor)
            if let terminal = session.terminal {
                TerminalScreen(bridge: terminal, isActive: tab == .terminal)
                    .opacity(tab == .terminal ? 1 : 0)
                    .scaleEffect(tab == .terminal || reduceMotion ? 1 : 0.98)
                    .allowsHitTesting(tab == .terminal)
                    .accessibilityHidden(tab != .terminal)
            }
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : Theme.spring, value: tab)
        .navigationTitle(server.displayName)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("视图", selection: $tab) {
                    Label("监控", systemImage: "waveform.path.ecg").tag(DetailTab.monitor)
                    Label("终端", systemImage: "terminal").tag(DetailTab.terminal)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 200)
            }
        }
        .onChange(of: tab) { _, newTab in
            openTerminalIfNeeded(newTab)
        }
    }

    /// The PTY is only created the first time the terminal tab is opened.
    private func openTerminalIfNeeded(_ tab: DetailTab) {
        if tab == .terminal { session.openTerminal() }
    }
}
