//
//  PasscodeSettingViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import Observation
import Foundation

@Observable
final class PasscodeSettingViewModel {
    var appSettings: AppSettings
    private let passcodeService: PasscodeService
    private let biometricAuthenticationService: BiometricAuthenticationService
    
    //var errorMessage: String?
    var isPasscodeSet: Bool
    
    var showSetPasscode: Bool = false
    var showRemovePasscode: Bool = false
    
    var isBiometrySupported: Bool
    
    var toast: ToastData?
    
    init(appSettings: AppSettings, passcodeService: PasscodeService, biometricAuthenticationService: BiometricAuthenticationService) {
        self.appSettings = appSettings
        self.passcodeService = passcodeService
        self.biometricAuthenticationService = biometricAuthenticationService
        
        self.isPasscodeSet = passcodeService.isPasscodeSet()
        self.isBiometrySupported = biometricAuthenticationService.isBiometrySupported()

    }
    
    func setPasscode(
        _ passcode: String
    ) -> Result<Void, PasscodeError> {
        do {
            try passcodeService.setPasscode(passcode)

            isPasscodeSet = true

            return .success(())
          } catch let error as PasscodeError {
              return .failure(error)
          } catch {
              return .failure(.keychain(-1))
          }
    }
    
    func chagePasscode(from oldPasscode: String, to newPasscode: String) {
        do {
            try passcodeService.changePasscode(from: oldPasscode, to: newPasscode)
            toast = .success("パスコードを変更しました")
        } catch {
            toast = .error("パスコードの変更に失敗しました")
        }
    }
    
    func removePasscode(_ passcode: String) -> Result<Void, PasscodeError> {
        do {
            try passcodeService.removePasscode(passcode)
            isPasscodeSet = false
            appSettings.isBiometricAuthenticationOn = false
            return .success(())
          } catch let error as PasscodeError {
              return .failure(error)
          } catch {
              return .failure(.keychain(-1))
          }
    }
    
    func toggleBiometricAuthentication() async {
        if appSettings.isBiometricAuthenticationOn {
            appSettings.isBiometricAuthenticationOn = false
            return
        }

        do {
            try await biometricAuthenticationService.authenticate()

            appSettings.isBiometricAuthenticationOn = true
            toast = .success("生体認証の設定に成功しました")

        } catch let error as BiometricAuthenticationError {
            toast = .error(error.localizedDescription)

        } catch {
            toast = .error("生体認証の設定に失敗しました")
        }
    }
    
    /*
    private func errorMessage(for error: Error) -> String {
        if let error = error as? PasscodeError {
            switch error {
            case .alreadySet:
                return "パスコードはすでに設定されています"
            case .invalidPasscode:
                return "パスコードが正しくありません"
            case .keychain:
                return "パスコードの保存に失敗しました"
            }
        }
        
        return "エラーが発生しました"
    }
     */
}
