import SwiftUI
import Charts

/// Last 40 samples as a smooth area chart. Index = sample slot, so offsets are the intended x values.
struct RateChart: View {
    let history: [Double]
    let color: Color

    var body: some View {
        Chart(Array(history.enumerated()), id: \.offset) { index, value in
            AreaMark(x: .value("t", index), y: .value("v", value))
                .foregroundStyle(LinearGradient(colors: [color.opacity(0.35), color.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("t", index), y: .value("v", value))
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round))
                .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: 0...39)
        .frame(height: 80)
        .animation(.easeInOut(duration: 0.6), value: history)
        .accessibilityHidden(true)
    }
}
