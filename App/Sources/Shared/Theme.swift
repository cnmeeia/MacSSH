import SwiftUI

enum Theme {
    static let accent  = Color(red: 0.00, green: 0.48, blue: 1.00)   // Apple blue
    static let accent2 = Color(red: 0.35, green: 0.78, blue: 0.98)   // light blue
    static let purple  = Color(red: 0.69, green: 0.32, blue: 0.87)
    static let green   = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let orange  = Color(red: 1.00, green: 0.62, blue: 0.04)
    static let track   = Color.black.opacity(0.06)
    static let label2  = Color.black.opacity(0.48)
    static let spring  = Animation.spring(response: 0.45, dampingFraction: 0.82)
}
