import Foundation
import Observation
import MonitorCore

/// Everything live for one server: its SSH connection, dashboard data and (once opened) its terminal.
/// Kept in `SessionPool`, so switching servers and coming back is instant and keeps terminal history.
@MainActor
@Observable
final class ServerSession {
    @ObservationIgnored let connection: SSHConnection
    @ObservationIgnored let dashboard: DashboardModel
    private(set) var terminal: TerminalBridge?

    init(endpoint: ServerEndpoint) {
        connection = SSHConnection(endpoint)
        dashboard = DashboardModel(connection: connection)
    }

    /// Start the handshake early, before any view asks for data.
    func warmUp() {
        let connection = connection
        Task { await connection.warmUp() }
    }

    func openTerminal() {
        if terminal == nil { terminal = TerminalBridge(connection: connection) }
    }

    func close() {
        terminal?.close()
        let connection = connection
        Task { await connection.close() }
    }
}
