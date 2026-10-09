import SwiftUI

/// Sidebar of servers + detail. Selection is per-window scene state.
struct RootView: View {
    @Environment(ServerStore.self) private var store
    @State private var selection: ServerProfile.ID?
    @State private var editing: ServerProfile?

    var body: some View {
        NavigationSplitView {
            ServerList(selection: $selection, editing: $editing)
        } detail: {
            if let server = store.server(id: selection) {
                ServerDetailView(server: server, session: store.session(for: server))
                    .id(server.id)
            } else {
                ZStack {
                    AppBackground()
                    ContentUnavailableView("选择一台服务器", systemImage: "gauge.with.dots.needle.33percent")
                }
            }
        }
        .sheet(item: $editing) { server in
            ServerEditView(server: server)
        }
        .onChange(of: selection) { _, id in
            warmUp(id)
        }
    }

    /// Start the SSH handshake the moment a server is tapped, before the detail asks for it.
    private func warmUp(_ id: ServerProfile.ID?) {
        guard let server = store.server(id: id) else { return }
        store.warmUp(server)
    }
}
