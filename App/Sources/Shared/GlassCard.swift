import SwiftUI

/// Frosted-glass card. Liquid Glass on iOS 26 / macOS 26 when built with Xcode 26+, system material otherwise.
struct GlassCard: ViewModifier {
    var radius: Double = 22

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        #if compiler(>=6.2)
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular, in: shape)
                .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
        } else {
            content.modifier(MaterialCard(shape: shape))
        }
        #else
        content.modifier(MaterialCard(shape: shape))
        #endif
    }
}

extension View {
    func glassCard(radius: Double = 22) -> some View { modifier(GlassCard(radius: radius)) }
}
