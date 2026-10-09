import SwiftUI

/// Fade + rise in, staggered by index. With Reduce Motion on, it only fades.
struct AppearIn: ViewModifier {
    let delay: Double
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 14)
            .scaleEffect(shown || reduceMotion ? 1 : 0.985)
            .onAppear(perform: show)
    }

    private func show() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : Theme.spring.delay(delay)) { shown = true }
    }
}

extension View {
    func appear(_ index: Int) -> some View { modifier(AppearIn(delay: Double(index) * 0.05)) }
}
