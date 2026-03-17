import SwiftUI

@main
struct PocketMuxApp: App {
    @StateObject private var connectionManager = SSHConnectionManager()

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environmentObject(connectionManager)
        }
    }
}

/// Routes the top-level UI based on connection state.
struct ContentRootView: View {
    @EnvironmentObject var connectionManager: SSHConnectionManager

    var body: some View {
        switch connectionManager.state {
        case .disconnected:
            HostSetupView()
        case .verifyingHost(let fingerprint):
            HostKeyVerificationView(fingerprint: fingerprint)
        case .connected:
            SessionListView()
        case .reconnecting:
            // Full-screen reconnect — SessionListView handles inline overlay for short gaps.
            ReconnectOverlayView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
        }
    }
}
