import SwiftUI

struct ErrorState: View {
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(Theme.orange)
                .symbolEffect(.pulse)
                .accessibilityHidden(true)
            Text("连接失败").font(.headline)
            Text(message).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Text("正在自动重连").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}
