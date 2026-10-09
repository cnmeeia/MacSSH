import SwiftUI

/// Soft white background with faint colour blobs so the glass has something to refract.
struct AppBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.968, blue: 0.976)
            Circle().fill(Theme.accent2.opacity(0.18)).frame(width: 520).blur(radius: 120).offset(x: -260, y: -280)
            Circle().fill(Theme.purple.opacity(0.10)).frame(width: 460).blur(radius: 120).offset(x: 300, y: 120)
            Circle().fill(Theme.green.opacity(0.07)).frame(width: 380).blur(radius: 110).offset(x: -120, y: 420)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
