import Foundation
import Observation
import MonitorCore

@MainActor
@Observable
final class ServerStore {
    var servers: [ServerProfile] = [] { didSet { persist() } }
    @ObservationIgnored private let key = "servers.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([ServerProfile].self, from: data) {
            servers = saved
        }
    }

    func server(id: ServerProfile.ID?) -> ServerProfile? {
        guard let id else { return nil }
        return servers.first { $0.id == id }
    }

    func secret(for server: ServerProfile) -> String { Keychain.get("secret.\(server.id)") ?? "" }
    func passphrase(for server: ServerProfile) -> String? { Keychain.get("pass.\(server.id)") }

    func save(_ server: ServerProfile, secret: String, passphrase: String) {
        Keychain.set(secret, for: "secret.\(server.id)")
        Keychain.set(passphrase, for: "pass.\(server.id)")
        SessionPool.shared.invalidate(server.id)
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
        } else {
            servers.append(server)
        }
    }

    func delete(_ server: ServerProfile) {
        Keychain.set(nil, for: "secret.\(server.id)")
        Keychain.set(nil, for: "pass.\(server.id)")
        SessionPool.shared.invalidate(server.id)
        servers.removeAll { $0.id == server.id }
    }

    /// The live session for a server. The Keychain is read only when the session is first created.
    func session(for server: ServerProfile) -> ServerSession {
        SessionPool.shared.session(for: server.id) { endpoint(server) }
    }

    func warmUp(_ server: ServerProfile) {
        session(for: server).warmUp()
    }

    private func endpoint(_ server: ServerProfile) -> ServerEndpoint {
        server.endpoint(secret: secret(for: server), passphrase: passphrase(for: server))
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(servers) { UserDefaults.standard.set(data, forKey: key) }
    }
}
