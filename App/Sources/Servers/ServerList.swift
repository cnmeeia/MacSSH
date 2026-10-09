import SwiftUI

struct ServerList: View {
    @Environment(ServerStore.self) private var store
    @Binding var selection: ServerProfile.ID?
    @Binding var editing: ServerProfile?

    var body: some View {
        List(selection: $selection) {
            Section("服务器") {
                ForEach(store.servers) { server in
                    ServerRow(server: server)
                        .tag(server.id)
                        .contextMenu {
                            Button("编辑", systemImage: "pencil") { editing = server }
                            Button("删除", systemImage: "trash", role: .destructive) { delete(server) }
                        }
                        #if os(iOS)
                        .swipeActions {
                            Button("删除", systemImage: "trash", role: .destructive) { delete(server) }
                            Button("编辑", systemImage: "pencil") { editing = server }
                                .tint(Theme.accent)
                        }
                        #endif
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background { AppBackground() }
        .navigationTitle("SSHMon")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("添加服务器", systemImage: "plus", action: addServer)
            }
        }
        .overlay {
            if store.servers.isEmpty {
                ContentUnavailableView("还没有服务器", systemImage: "server.rack",
                                       description: Text("点右上角 + 添加，用 SSH 连接即可，服务器上不用装任何东西。"))
            }
        }
    }

    private func addServer() { editing = ServerProfile() }

    private func delete(_ server: ServerProfile) {
        if selection == server.id { selection = nil }
        withAnimation(Theme.spring) { store.delete(server) }
    }
}
