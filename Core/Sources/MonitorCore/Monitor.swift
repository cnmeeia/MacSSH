import Foundation

/// Polls a server every `interval` seconds and yields snapshots.
/// An actor, so the previous raw sample (needed for CPU / network rates) is never raced.
public actor Monitor {
    public let connection: SSHConnection
    public let interval: Duration
    private var previous: RawSample?

    public init(connection: SSHConnection, interval: Duration = .seconds(3)) {
        self.connection = connection
        self.interval = interval
    }

    public func sampleOnce() async throws -> Snapshot {
        let output = try await connection.run(RemoteCommand.script)
        let current = Parser.parse(output)
        let snapshot = Parser.snapshot(prev: previous, cur: current)
        previous = current
        return snapshot
    }

    /// First frame immediately (load / memory / disks); CPU and network rates fill in a second later.
    public nonisolated func stream() -> AsyncThrowingStream<Snapshot, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    continuation.yield(try await self.sampleOnce())
                    try await Task.sleep(for: .seconds(1))
                    while !Task.isCancelled {
                        continuation.yield(try await self.sampleOnce())
                        try await Task.sleep(for: self.interval)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
