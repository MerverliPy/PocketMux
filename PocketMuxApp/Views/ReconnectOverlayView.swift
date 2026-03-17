import SwiftUI

/// Shown when the connection is being re-established after a background/foreground cycle
/// or a transient network interruption.
struct ReconnectOverlayView: View {
    @EnvironmentObject var connectionManager: SSHConnectionManager

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Reconnecting…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Cancel") {
                Task { await connectionManager.disconnect() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(28)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
