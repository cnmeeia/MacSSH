import SwiftUI

extension Text {
    /// `percent` is 0…100, as the server reports it.
    init(percent: Double, digits: Int = 1) {
        self.init(percent / 100, format: .percent.precision(.fractionLength(digits)))
    }
}
