import Foundation
import MonitorCore

struct ServerProfile: Identifiable, Codable, Hashable {
    enum AuthKind: String, Codable, CaseIterable, Identifiable {
        case password = "密码", key = "私钥"
        var id: Self { self }
    }

    var id = UUID()
    var name = ""
    var host = ""
    var port = 22
    var username = "root"
    var authKind: AuthKind = .password

    var displayName: String { name.isEmpty ? host : name }

    /// `secret` is the password or the private-key text, both kept in the Keychain.
    func endpoint(secret: String, passphrase: String?) -> ServerEndpoint {
        ServerEndpoint(host: host, port: port, username: username,
                       auth: authKind == .password ? .password(secret) : .privateKey(secret, passphrase: passphrase))
    }
}
