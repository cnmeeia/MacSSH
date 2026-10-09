import Foundation
@preconcurrency import Citadel   // SSHClient is not Sendable yet; it is NIO-backed and safe to share
import NIOCore
import NIOSSH

/// What a shell session reports, in order.
public enum ShellEvent: Sendable {
    case output([UInt8])
    case closed(String?)
}

/// Interactive PTY shell. Write with `send`, read everything from the ordered `events` stream.
/// `@unchecked Sendable`: every mutable field is only touched inside `lock`.
@available(iOS 18.0, macOS 15.0, *)
public final class ShellSession: @unchecked Sendable {
    public let events: AsyncStream<ShellEvent>

    private let connection: SSHConnection
    private let continuation: AsyncStream<ShellEvent>.Continuation
    private let lock = NSLock()
    private var writer: TTYStdinWriter?
    private var task: Task<Void, Never>?
    private var pending: [UInt8] = []
    private var size: (cols: Int, rows: Int)?

    public init(connection: SSHConnection) {
        self.connection = connection
        (events, continuation) = AsyncStream.makeStream(bufferingPolicy: .unbounded)
    }

    public func start(cols: Int, rows: Int) {
        let task = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.runPTY(cols: cols, rows: rows)
                self.continuation.yield(.closed(nil))
            } catch {
                self.continuation.yield(.closed(Task.isCancelled ? nil : error.localizedDescription))
            }
            self.continuation.finish()
        }
        lock.withLock { self.task = task }
    }

    private func runPTY(cols: Int, rows: Int) async throws {
        let client = try await connection.connect()
        let request = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true, term: "xterm-256color",
            terminalCharacterWidth: cols, terminalRowHeight: rows,
            terminalPixelWidth: 0, terminalPixelHeight: 0,
            terminalModes: .init([.ECHO: 1]))
        try await client.withPTY(request) { inbound, outbound in
            let (early, latestSize): ([UInt8], (cols: Int, rows: Int)?) = self.lock.withLock {
                self.writer = outbound
                defer { self.pending = [] }
                return (self.pending, self.size)
            }
            if !early.isEmpty { try await outbound.write(ByteBuffer(bytes: early)) }
            if let latestSize, latestSize != (cols, rows) {
                try? await outbound.changeSize(cols: latestSize.cols, rows: latestSize.rows, pixelWidth: 0, pixelHeight: 0)
            }
            for try await chunk in inbound {
                switch chunk {
                case .stdout(let buffer), .stderr(let buffer):
                    self.continuation.yield(.output(Array(buffer.readableBytesView)))
                }
            }
        }
    }

    public func send(_ bytes: [UInt8]) {
        let writer: TTYStdinWriter? = lock.withLock {
            if self.writer == nil { pending += bytes }
            return self.writer
        }
        guard let writer else { return }
        Task { try? await writer.write(ByteBuffer(bytes: bytes)) }
    }

    public func send(_ text: String) { send(Array(text.utf8)) }

    public func resize(cols: Int, rows: Int) {
        let writer = lock.withLock { size = (cols, rows); return self.writer }
        guard let writer else { return }
        Task { try? await writer.changeSize(cols: cols, rows: rows, pixelWidth: 0, pixelHeight: 0) }
    }

    public func close() {
        let task = lock.withLock { () -> Task<Void, Never>? in
            defer { self.task = nil; self.writer = nil }
            return self.task
        }
        task?.cancel()
    }
}
