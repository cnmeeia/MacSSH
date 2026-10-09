import SwiftUI

/// Pre-26 fallback for `GlassCard`.
struct MaterialCard: ViewModifier {
    let shape: RoundedRectangle

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: shape)
            .background(Color.white.opacity(0.55), in: shape)
            .overlay { shape.strokeBorder(Color.white.opacity(0.9), lineWidth: 1) }
            .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }
}
