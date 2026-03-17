import Foundation
import Security

/// Describes one remote host the user connects to.
/// Stored in iOS Keychain — never written to disk in plaintext.
struct HostProfile: Codable, Identifiable {
    let id: UUID
    var hostname: String
    var port: UInt16
    var username: String
    var authMethod: AuthMethod

    enum AuthMethod: Codable {
        /// Tag identifying a private key in the Keychain.
        case publicKey(privateKeyTag: String)
        /// Password is stored separately in Keychain under a per-profile item.
        /// Never serialised inline.
        case password
    }

    init(
        id: UUID = UUID(),
        hostname: String,
        port: UInt16 = 22,
        username: String,
        authMethod: AuthMethod
    ) {
        self.id = id
        self.hostname = hostname
        self.port = port
        self.username = username
        self.authMethod = authMethod
    }
}

// MARK: - Keychain persistence

extension HostProfile {
    private static let keychainAccount = "pocketmux.host_profile"

    /// Load the saved host profile from Keychain. Returns nil if none exists.
    static func load() -> HostProfile? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainAccount,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(HostProfile.self, from: data)
    }

    /// Persist the host profile to Keychain, replacing any existing entry.
    func save() throws {
        let data = try JSONEncoder().encode(self)
        let baseQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: HostProfile.keychainAccount,
        ]

        let updateAttrs: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemUpdate(baseQuery as CFDictionary, updateAttrs as CFDictionary)
        if status == errSecItemNotFound {
            var insert = baseQuery
            insert[kSecValueData] = data
            insert[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let insertStatus = SecItemAdd(insert as CFDictionary, nil)
            guard insertStatus == errSecSuccess else {
                throw KeychainError.writeFailed(insertStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.writeFailed(status)
        }
    }

    static func delete() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainAccount,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Password Keychain helpers

extension HostProfile {
    /// Account key used to store the password for this profile.
    var passwordKeychainAccount: String { "pocketmux.password.\(id.uuidString)" }

    func savePassword(_ password: String) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeychainError.writeFailed(errSecParam)
        }

        let baseQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: passwordKeychainAccount,
        ]

        let updateAttrs: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemUpdate(baseQuery as CFDictionary, updateAttrs as CFDictionary)
        if status == errSecItemNotFound {
            var insert = baseQuery
            insert[kSecValueData] = data
            insert[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let insertStatus = SecItemAdd(insert as CFDictionary, nil)
            guard insertStatus == errSecSuccess else {
                throw KeychainError.writeFailed(insertStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.writeFailed(status)
        }
    }

    func loadPassword() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: passwordKeychainAccount,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func deletePassword() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: passwordKeychainAccount,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case writeFailed(OSStatus)
}
