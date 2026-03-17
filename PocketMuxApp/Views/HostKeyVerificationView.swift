import SwiftUI

/// Shown when the SSH handshake surfaces an unrecognised host key.
/// The user must explicitly approve or reject before the connection continues.
struct HostKeyVerificationView: View {
    let fingerprint: String
    @EnvironmentObject var connectionManager: SSHConnectionManager

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Verify Host Key")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Fingerprint")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(fingerprint)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            Text("Verify this fingerprint matches your server before trusting it. If it changes on a future connection, it will be refused automatically.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button(role: .destructive) {
                    connectionManager.pendingHostKey?.reject()
                } label: {
                    Label("Reject", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    connectionManager.pendingHostKey?.approve()
                } label: {
                    Label("Trust & Connect", systemImage: "checkmark.shield")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
