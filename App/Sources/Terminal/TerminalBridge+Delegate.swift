import SwiftUI
import SwiftTerm

/// SwiftTerm calls its delegate on the main thread.
extension TerminalBridge: @preconcurrency TerminalViewDelegate {
    func send(source: TerminalView, data: ArraySlice<UInt8>) { session.send(Array(data)) }
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) { session.resize(cols: newCols, rows: newRows) }
    func setTerminalTitle(source: TerminalView, title: String) {}
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    func scrolled(source: TerminalView, position: Double) {}
    func bell(source: TerminalView) {}
    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
    func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}

    func requestOpenLink(source: TerminalView, link: String, params: [String: String]) {
        guard let url = URL(string: link) else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }

    func clipboardCopy(source: TerminalView, content: Data) {
        let text = String(decoding: content, as: UTF8.self)
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }

    func clipboardRead(source: TerminalView) -> Data? {
        #if os(macOS)
        return NSPasteboard.general.string(forType: .string).map { Data($0.utf8) }
        #else
        return UIPasteboard.general.string.map { Data($0.utf8) }
        #endif
    }
}
