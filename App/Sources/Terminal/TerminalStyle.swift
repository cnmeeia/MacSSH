import SwiftUI
import SwiftTerm

/// Light "Apple white" terminal palette.
@MainActor
enum TerminalStyle {
    static func apply(to view: TerminalView) {
        #if os(macOS)
        view.nativeBackgroundColor = .clear
        view.nativeForegroundColor = NSColor(white: 0.12, alpha: 1)
        view.caretColor = .systemBlue
        #else
        view.nativeBackgroundColor = .clear
        view.backgroundColor = .clear
        view.nativeForegroundColor = UIColor(white: 0.12, alpha: 1)
        view.caretColor = .systemBlue
        #endif
    }
}
