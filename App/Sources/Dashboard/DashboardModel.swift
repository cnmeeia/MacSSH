import Foundation
import Observation
import MonitorCore

@MainActor
@Observable
final class DashboardModel {
    private(set) var snapshot: Snapshot?
    private(set) var error: String?
    private(set) var rxHistory: [Double] = []
    private(set) var txHistory: [Double] = []
    private(set) var connectMillis: Int?
    let interval: Duration = .seconds(3)

    @ObservationIgnored private let connection: SSHConnection
    @ObservationIgnored private var isRunning = false
    private static let historyLength = 40

    init(connection: SSHConnection) { self.connection = connection }

    /// Streams snapshots until the calling task is cancelled (the view's `task()` does that on disappear).
    /// Reconnects with a 1/2/4/8 s back-off.
    func run() async {
        guard !isRunning else { return }
        isRunning = true
        defer { isRunning = false }

        var retry = 1
        while !Task.isCancelled {
            let started = Date.now
            let monitor = Monitor(connection: connection, interval: interval)
            do {
                for try await snapshot in monitor.stream() {
                    if connectMillis == nil { connectMillis = Int(Date.now.timeIntervalSince(started) * 1000) }
                    retry = 1
                    apply(snapshot)
                }
            } catch {
                if Task.isCancelled { break }
                self.error = error.localizedDescription
            }
            if Task.isCancelled { break }
            try? await Task.sleep(for: .seconds(retry))
            retry = min(retry * 2, 8)
        }
    }

    private func apply(_ snapshot: Snapshot) {
        error = nil
        self.snapshot = snapshot
        guard snapshot.hasRates else { return }
        rxHistory = Self.appending(snapshot.totalRx, to: rxHistory)
        txHistory = Self.appending(snapshot.totalTx, to: txHistory)
    }

    private static func appending(_ value: Double, to history: [Double]) -> [Double] {
        var history = history
        history.append(value)
        if history.count > historyLength { history.removeFirst(history.count - historyLength) }
        return history
    }
}
