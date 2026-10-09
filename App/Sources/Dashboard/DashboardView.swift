import SwiftUI
import MonitorCore

/// Read-only dashboard: no text inputs, so it never raises the keyboard.
struct DashboardView: View {
    let server: ServerProfile
    let model: DashboardModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DashboardHeader(server: server, model: model)
                    if let snapshot = model.snapshot {
                        if proxy.size.width >= 860 {
                            WideDashboard(s: snapshot, model: model)
                        } else {
                            NarrowDashboard(s: snapshot, model: model)
                        }
                    } else if let error = model.error {
                        ErrorState(message: error)
                    } else {
                        LoadingState()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .task { await model.run() }
    }
}
