import SwiftUI

/// Wraps several glass cards in one `GlassEffectContainer` on iOS 26 / macOS 26 so they render
/// in a single pass. Spacing 0 keeps separate cards from melting into each other.
/// Plain passthrough on older systems.
struct GlassGroup<Content: View>: View {
    var spacing: Double = 0
    @ViewBuilder let content: Content

    var body: some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}
