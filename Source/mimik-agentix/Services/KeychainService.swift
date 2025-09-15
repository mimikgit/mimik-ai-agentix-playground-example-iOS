//
//  KeychainService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-15.
//

import Foundation
import Security

struct KeychainService {
    
    // Stores a value securely in the Keychain.
    static func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            print("⚠️ Failed to encode value for key: \(key)")
            return
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)

        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecSuccess {
            print("✅ Keychain save \(key) success")
        }
        else {
            print("⚠️ Keychain save \(key) failed with status: \(status)")
        }
    }

    // Retrieves a value from the Keychain.
    static func read(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
           return value
        }
        else if status == errSecItemNotFound {
            return nil
        }
        else {
            print("⚠️ Keychain read \(key) failed with status: \(status)")
            return nil
        }
    }

    // Deletes a value from the Keychain.
    static func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            print("✅ Delete \(key) successful")
        default:
            print("⚠️ Keychain delete \(key) failed with status: \(status)")
        }
    }
}
