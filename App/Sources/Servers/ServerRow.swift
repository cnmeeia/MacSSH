import SwiftUI

struct ServerRow: View {
    let server: ServerProfile

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(LinearGradient(colors: [Theme.accent2, Theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: .rect(cornerRadius: 9, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(server.displayName).font(.body.weight(.medium))
                Text(verbatim: "\(server.username)@\(server.host):\(server.port)")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 3)
    }
}
