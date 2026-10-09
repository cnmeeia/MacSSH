import SwiftUI
import MonitorCore

struct CPUCard: View {
    let s: Snapshot
    @State private var showCores = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Card("处理器 · \(s.host.cores) 核") {
            VStack(alignment: .leading) {
                if showCores {
                    CoreGrid(perCore: s.perCore)
                        .transition(slide(from: .trailing))
                } else {
                    CPUOverview(cpu: s.cpu)
                        .transition(slide(from: .leading))
                }
            }
        } trailing: {
            SegmentToggle(title: "处理器视图", right: $showCores, left: "总览", rightLabel: "每核")
        }
    }

    private func slide(from edge: Edge) -> AnyTransition {
        reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: edge).combined(with: .opacity), removal: .opacity)
    }
}
