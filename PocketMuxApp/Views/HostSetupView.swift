import SwiftUI

/// Entry point for new users. Collects host connection details and initiates SSH connect.
struct HostSetupView: View {
    @EnvironmentObject var connectionManager: SSHConnectionManager

    @State private var hostname = ""
    @State private var port = "22"
    @State private var username = ""
    @State private var password = ""
    @State private var isConnecting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Host") {
                    TextField("Hostname or IP", text: $hostname)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }

                Section("Authentication") {
                    TextField("Username", text: $username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }
            }
            .navigationTitle("Connect to Host")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") { beginConnect() }
                        .disabled(!isFormValid || isConnecting)
                }
            }
            .disabled(isConnecting)
            .overlay {
                if isConnecting {
                    ProgressView("Connecting…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var isFormValid: Bool {
        !hostname.isEmpty && !username.isEmpty && !password.isEmpty && UInt16(port) != nil
    }

    private func beginConnect() {
        guard let portNumber = UInt16(port) else { return }
        isConnecting = true

        var profile = HostProfile(
            hostname: hostname,
            port: portNumber,
            username: username,
            authMethod: .password
        )

        // Persist credentials — password goes to Keychain, profile blob also to Keychain.
        do {
            try profile.savePassword(password)
            try profile.save()
        } catch {
            // Non-fatal for this iteration: connection can still proceed in-memory.
        }

        Task {
            await connectionManager.connect(to: profile)
            isConnecting = false
        }
    }
}
