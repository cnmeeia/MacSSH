import SwiftUI

@main
struct SSHMonApp: App {
    @State private var store = ServerStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.light)   // 苹果白：整窗浅色
                .tint(Theme.accent)
        }
        #if os(macOS)
        .defaultSize(width: 1180, height: 780)
        #endif
    }
}
