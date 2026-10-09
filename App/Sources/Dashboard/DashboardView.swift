import SwiftUI
import MonitorCore

/// Read-only dashboard: no text inputs, so it never raises the keyboard.
struct DashboardView: View {
    let server: ServerProfile
    let model: DashboardModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DashboardHeader(server: server, model: model)
                if let snapshot = model.snapshot {
                    ViewThatFits(in: .horizontal) {
                        WideDashboard(s: snapshot, model: model).frame(minWidth: 820)
                        NarrowDashboard(s: snapshot, model: model)
                    }
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                } else if let error = model.error {
                    ErrorState(message: error).transition(.opacity)
                } else {
                    LoadingState().transition(.opacity)
                }
            }
            .padding(20)
            .animation(Theme.spring, value: model.snapshot == nil)
            .animation(.snappy, value: model.snapshot?.time)   // numbers roll on every refresh
        }
        .scrollDismissesKeyboard(.immediately)
        .task { await model.run() }
    }
}
