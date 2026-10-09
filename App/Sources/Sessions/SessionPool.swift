import Foundation
import MonitorCore

/// One `ServerSession` per server, created on first use and reused afterwards.
@MainActor
final class SessionPool {
    static let shared = SessionPool()
    private var sessions: [UUID: ServerSession] = [:]

    /// `endpoint` is evaluated only when a new session is needed (it reads the Keychain).
    func session(for id: UUID, endpoint: () -> ServerEndpoint) -> ServerSession {
        if let existing = sessions[id] { return existing }
        let session = ServerSession(endpoint: endpoint())
        sessions[id] = session
        return session
    }

    func invalidate(_ id: UUID) {
        sessions.removeValue(forKey: id)?.close()
    }
}
