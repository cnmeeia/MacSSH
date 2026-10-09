import SwiftUI
import Observation
import SwiftTerm
import MonitorCore

/// Owns the SSH PTY and the SwiftTerm view, so terminal history survives tab and server switches.
/// Output arrives through the session's ordered AsyncStream and is drained on the main actor.
@MainActor
@Observable
final class TerminalBridge: NSObject {
    private(set) var closedReason: String?

    @ObservationIgnored private let connection: SSHConnection
    @ObservationIgnored private(set) var session: ShellSession   // read by the delegate extension
    @ObservationIgnored private var pump: Task<Void, Never>?
    @ObservationIgnored private var started = false
    @ObservationIgnored private(set) lazy var view: TerminalView = makeTerminalView()

    init(connection: SSHConnection) {
        self.connection = connection
        session = ShellSession(connection: connection)
        super.init()
        wire()
    }

    /// Opens the PTY once the view has a real size.
    func startIfNeeded() {
        guard !started else { return }
        started = true
        let terminal = view.getTerminal()
        session.start(cols: max(terminal.cols, 20), rows: max(terminal.rows, 5))
    }

    func reconnect() {
        session.close()
        session = ShellSession(connection: connection)
        wire()
        closedReason = nil
        started = false
        view.feed(text: "\u{1B}[2J\u{1B}[H")
        startIfNeeded()
    }

    func close() {
        pump?.cancel()
        session.close()
    }

    /// Drains the session's ordered event stream on the main actor.
    private func wire() {
        pump?.cancel()
        let events = session.events
        pump = Task { [weak self] in
            for await event in events {
                guard let self else { return }
                self.handle(event)
            }
        }
    }

    private func handle(_ event: ShellEvent) {
        switch event {
        case .output(let bytes):
            view.feed(byteArray: bytes[...])
        case .closed(let reason):
            closedReason = reason ?? "会话已结束"
            view.feed(text: "\r\n\u{1B}[33m[连接已关闭]\u{1B}[0m\r\n")
        }
    }

    private func makeTerminalView() -> TerminalView {
        #if os(macOS)
        let terminal = TerminalView(frame: NSRect(x: 0, y: 0, width: 800, height: 500))
        terminal.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        #else
        let terminal = TerminalView(frame: CGRect(x: 0, y: 0, width: 390, height: 600))
        terminal.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        terminal.keyboardAppearance = .light
        #endif
        TerminalStyle.apply(to: terminal)
        terminal.terminalDelegate = self
        return terminal
    }
}
