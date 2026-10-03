//
//  BiometricAuthenticationService.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/03.
//

import LocalAuthentication

final class BiometricAuthenticationService {
    
    func isBiometrySupported() -> Bool {
        let context = LAContext()
        var error: NSError?

        context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        switch context.biometryType {
             case .none:
                 return false

             case .touchID:
                 return true

             case .faceID:
                 return true

             case .opticID:
                 return true

             @unknown default:
                 return false
         }
    }
    
    func isAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
    }
    
    func biometryType() -> LABiometryType {
            let context = LAContext()
        var error: NSError?
        
        context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        return context.biometryType
    }
    
    func authenticate() async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            if let error = error as? LAError {
                throw mapError(error)
            }

            throw BiometricAuthenticationError.failed
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "家計簿を開くために認証してください"
            )
        } catch let error as LAError {
            throw mapError(error)
        } catch {
            throw BiometricAuthenticationError.failed
        }
    }
    
    private func mapError(_ error: LAError) -> BiometricAuthenticationError {
        switch error.code {
        case .biometryNotAvailable:
            return .notAvailable

        case .biometryNotEnrolled:
            return .notEnrolled

        case .biometryLockout:
            return .lockout

        case .userCancel:
            return .userCancel

        case .userFallback:
            return .userFallback

        case .systemCancel:
            return .systemCancel

        default:
            return .failed
        }
    }
}
