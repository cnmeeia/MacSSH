import SwiftUI

/// Rounded progress bar. GeometryReader is kept: the fill width depends on the bar's own width.
struct Bar: View {
    let fraction: Double
    let color: Color
    var height = 7.0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.track)
                Capsule()
                    .fill(LinearGradient(colors: [color.opacity(0.75), color], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, clamped * proxy.size.width))
                    .opacity(fraction > 0.001 ? 1 : 0)
            }
        }
        .frame(height: height)
        .animation(Theme.spring, value: fraction)
        .accessibilityHidden(true)
    }

    private var clamped: Double { min(1, max(0, fraction)) }
}
