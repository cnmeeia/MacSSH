import SwiftUI
import Charts
import MonitorCore

struct RateCard: View {
    let title: String
    let value: Double
    let history: [Double]
    let color: Color

    var body: some View {
        Card(title) {
            RateFigure(text: Format.bytesPerSec(value))
            RateChart(history: history, color: color)
        } trailing: {
            Text("峰值 \(Format.bytesPerSec(history.max() ?? 0))").font(.caption2).foregroundStyle(Theme.label2)
        }
    }
}
