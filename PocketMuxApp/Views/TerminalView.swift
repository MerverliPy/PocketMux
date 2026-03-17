import SwiftUI

/// STUB — terminal renderer not yet implemented.
///
/// This view is an explicit placeholder. Replace in a later slice with a
/// VT100/xterm-compatible renderer. A UIKit bridge will be required here
/// (e.g., wrapping SwiftTerm's TerminalView or a custom UIView).
///
/// The stub is intentionally visible so the integration is testable end-to-end
/// before the real renderer is wired in.
struct TerminalView: View {
    let sessionName: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("[\(sessionName)]")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.green)
                Text("Terminal renderer stub.\nReplace with VT100-compatible view.")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.green.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
