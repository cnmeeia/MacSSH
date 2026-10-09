import SwiftUI

/// Skeleton cards while the first sample arrives.
struct LoadingState: View {
    var body: some View {
        VStack(spacing: 14) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.5))
                    .frame(height: index == 0 ? 130 : 170)
                    .glassCard()
                    .phaseAnimator([0.45, 1.0]) { view, opacity in view.opacity(opacity) } animation: { _ in .easeInOut(duration: 0.9) }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("正在连接")
    }
}
