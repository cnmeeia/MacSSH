import SwiftUI
import MonitorCore

struct DisksCard: View {
    let s: Snapshot

    var body: some View {
        Card("磁盘 · \(s.disks.count) 个挂载点") {
            ForEach(s.disks) { disk in
                DiskRow(disk: disk)
            }
        }
    }
}
