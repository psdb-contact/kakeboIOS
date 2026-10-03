//
//  PasscodeService.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import Foundation
import Security
import CryptoKit

final class PasscodeService {
    private let service = "com.yourkakebo.passcode"
    private let account = "app-passcode"
    
    func isPasscodeSet() -> Bool {
            readPasscodeHash() != nil
    }
    
    func setPasscode(_ passcode: String) throws {
        let hash = hash(passcode)
        
        let data = Data(hash.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw PasscodeError.alreadySet
        default:
            throw PasscodeError.keychain(status)
        }
    }
    
    func verifyPasscode(_ passcode: String) -> Bool {
        guard let storedHash = readPasscodeHash() else {
                return false
        }
        
        return hash(passcode) == storedHash
    }
    
    func changePasscode(from oldPasscode: String, to newPasscode: String) throws {
        guard verifyPasscode(oldPasscode) else {
            throw PasscodeError.invalidPasscode
        }
        
        let newHash = hash(newPasscode)
        let data = Data(newHash.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        guard status == errSecSuccess else {
            throw PasscodeError.keychain(status)
        }
    }
    
    func removePasscode(_ passcode: String) throws {
        guard verifyPasscode(passcode) else {
            throw PasscodeError.invalidPasscode
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(
            query as CFDictionary
        )
        
        switch status {
            case errSecSuccess, errSecItemNotFound:
                return
            default:
                throw PasscodeError.keychain(status)
        }
    }
    
    private func readPasscodeHash() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let hash = String(data: data, encoding: .utf8)
        else {
              return nil
        }
        
        return hash
    }
    
    private func hash(_ passcode: String) -> String {
        let data = Data(passcode.utf8)
        let digest = SHA256.hash(data: data)
        
        return digest
            .map{String(format: "%02x", $0)}
            .joined()
    }
}
