import SwiftUI
import UIKit

/// A UIViewRepresentable terminal rendering surface.
///
/// Currently wraps UITextView as a display-only buffer. This provides a real
/// UIKit rendering surface and validates the UIViewRepresentable bridge that
/// full terminal renderers require.
///
/// Swap target (Slice 6 / Slice 7): Replace UITextView with SwiftTerm.TerminalView
/// and wire TerminalAttachmentCoordinator.onOutput directly into SwiftTerm's
/// `feed(byteArray:)` API for full VT100/xterm byte-stream rendering.
struct TerminalRendererView: UIViewRepresentable {
    let outputBuffer: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .black
        view.textColor = UIColor(red: 0, green: 0.85, blue: 0, alpha: 1)
        view.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        view.isEditable = false
        view.isScrollEnabled = true
        view.text = outputBuffer
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        guard uiView.text != outputBuffer else { return }
        uiView.text = outputBuffer
        let length = uiView.text.utf16.count
        guard length > 0 else { return }
        uiView.scrollRangeToVisible(NSRange(location: length - 1, length: 0))
    }
}
