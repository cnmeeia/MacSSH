import Foundation
@preconcurrency import Citadel   // SSHClient is not Sendable yet; it is NIO-backed and safe to share
import NIOCore
import NIOSSH
import Crypto

public enum AuthMethod: Sendable {
    case password(String)
    /// OpenSSH-format private key text (ed25519 or RSA), optional passphrase.
    case privateKey(String, passphrase: String?)
}

public struct ServerEndpoint: Sendable {
    public var host: String, port: Int, username: String, auth: AuthMethod
    public init(host: String, port: Int = 22, username: String, auth: AuthMethod) {
        self.host = host; self.port = port; self.username = username; self.auth = auth
    }
}

public enum SSHError: LocalizedError {
    case unsupportedKey
    public var errorDescription: String? { "不支持的私钥格式（请用 OpenSSH 格式的 ed25519 或 RSA 私钥）" }
}

/// One SSH connection shared by the dashboard and the terminal (each uses its own channel).
/// Concurrent callers of `connect()` share a single handshake.
/// `@unchecked Sendable`: every mutable field is only touched inside `lock`.
public final class SSHConnection: @unchecked Sendable {
    public let endpoint: ServerEndpoint
    private let lock = NSLock()
    private var _client: SSHClient?
    private var connecting: Task<SSHClient, Error>?
    public let connectTimeout: Int64

    public init(_ endpoint: ServerEndpoint, connectTimeout: Int64 = 8) {
        self.endpoint = endpoint
        self.connectTimeout = connectTimeout
    }

    /// Start the handshake without handing the (non-Sendable) client across isolation domains.
    public func warmUp() async {
        _ = try? await connect()
    }

    public var client: SSHClient? { lock.withLock { _client } }
    public var isConnected: Bool { lock.withLock { _client?.isConnected ?? false } }

    func authentication() throws -> SSHAuthenticationMethod {
        switch endpoint.auth {
        case .password(let pw):
            return .passwordBased(username: endpoint.username, password: pw)
        case .privateKey(let text, let pass):
            let passData = pass.flatMap { $0.isEmpty ? nil : $0.data(using: .utf8) }
            if let k = try? Curve25519.Signing.PrivateKey(sshEd25519: text, decryptionKey: passData) {
                return .ed25519(username: endpoint.username, privateKey: k)
            }
            if let k = try? Insecure.RSA.PrivateKey(sshRsa: text, decryptionKey: passData) {
                return .rsa(username: endpoint.username, privateKey: k)
            }
            throw SSHError.unsupportedKey
        }
    }

    @discardableResult
    public func connect() async throws -> SSHClient {
        let task: Task<SSHClient, Error> = try lock.withLock {
            if let c = _client, c.isConnected { return Task { c } }
            if let t = connecting { return t }
            let auth = try authentication()
            var settings = SSHClientSettings(
                host: endpoint.host, port: endpoint.port,
                authenticationMethod: { auth },
                hostKeyValidator: .acceptAnything() // TODO: TOFU host key pinning
            )
            settings.connectTimeout = .seconds(connectTimeout)
            let t = Task { try await SSHClient.connect(to: settings) }
            connecting = t
            return t
        }
        do {
            let c = try await task.value
            lock.withLock {
                _client = c; connecting = nil
            }
            let id = ObjectIdentifier(c)
            c.onDisconnect { [weak self] in
                guard let self else { return }
                self.lock.withLock {
                    if let current = self._client, ObjectIdentifier(current) == id { self._client = nil }
                }
            }
            return c
        } catch {
            lock.withLock { connecting = nil }
            throw error
        }
    }

    public func run(_ command: String) async throws -> String {
        let client = try await connect()
        var buf = try await client.executeCommand(command, maxResponseSize: 4 * 1024 * 1024, mergeStreams: false)
        return buf.readString(length: buf.readableBytes) ?? ""
    }

    public func close() async {
        let c: SSHClient? = lock.withLock { let c = _client; _client = nil; connecting?.cancel(); connecting = nil; return c }
        try? await c?.close()
    }
}
