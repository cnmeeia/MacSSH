import SwiftUI

/// Small pulsing status dot. Static when Reduce Motion is on.
struct PulseDot: View {
    var color: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.35))
                .phaseAnimator([false, true]) { view, on in
                    view.scaleEffect(on && !reduceMotion ? 2.2 : 1).opacity(on || reduceMotion ? 0 : 1)
                } animation: { _ in .easeOut(duration: 1.4) }
            Circle().fill(color)
        }
        .frame(width: 8, height: 8)
        .accessibilityHidden(true)
    }
}
