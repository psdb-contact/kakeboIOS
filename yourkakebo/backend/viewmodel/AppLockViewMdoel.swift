//
//  AppLockViewMdoel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/03.
//

import Observation
import Foundation

@Observable
final class AppLockViewModel {
    private let passcodeService: PasscodeService
    private let biometricAuthenticationService: BiometricAuthenticationService

    let appSettings: AppSettings

    var isUnlocked = false
    var isShowingPasscode = false
    var toast: ToastData?

    init(
        appSettings: AppSettings,
        passcodeService: PasscodeService,
        biometricAuthenticationService: BiometricAuthenticationService
    ) {
        self.appSettings = appSettings
        self.passcodeService = passcodeService
        self.biometricAuthenticationService = biometricAuthenticationService
    }
    
    func authenticate() async {
        guard passcodeService.isPasscodeSet() else {
            isUnlocked = true
            return
        }

        if appSettings.isBiometricAuthenticationOn {
            do {
                try await biometricAuthenticationService.authenticate()
                isUnlocked = true
            } catch {
                isShowingPasscode = true
            }

            return
        }

        isShowingPasscode = true
    }
    
    func verifyPasscode(_ passcode: String) -> Result<Void, PasscodeError> {
        guard passcodeService.verifyPasscode(passcode) else {
               return .failure(.invalidPasscode)
           }

           isUnlocked = true

           return .success(())
     }
}
