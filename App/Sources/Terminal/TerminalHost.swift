import SwiftUI
import SwiftTerm

/// Hosts the bridge's long-lived TerminalView.
/// Keyboard only on the terminal tab: focus while active, resign as soon as you leave.
#if os(macOS)
struct TerminalHost: NSViewRepresentable {
    let bridge: TerminalBridge
    let isActive: Bool

    func makeNSView(context: Context) -> TerminalView { bridge.view }

    func updateNSView(_ view: TerminalView, context: Context) {
        let active = isActive
        Task { @MainActor in
            if active {
                view.window?.makeFirstResponder(view)
            } else if view.window?.firstResponder === view {
                view.window?.makeFirstResponder(nil)
            }
        }
    }
}
#else
struct TerminalHost: UIViewRepresentable {
    let bridge: TerminalBridge
    let isActive: Bool

    func makeUIView(context: Context) -> TerminalView { bridge.view }

    func updateUIView(_ view: TerminalView, context: Context) {
        let active = isActive
        // Deferred one turn so the view is in a window before it asks for focus.
        Task { @MainActor in
            if active {
                if !view.isFirstResponder { _ = view.becomeFirstResponder() }
            } else if view.isFirstResponder {
                _ = view.resignFirstResponder()
            }
        }
    }
}
#endif
