//
//  AppLockView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/03.
//

import SwiftUI

struct AppLockView: View {
    @Environment(AppContainer.self) private var appContainer

    var body: some View {
        AppLockContentView(
            appSettings: appContainer.appSettings,
            passcodeService: appContainer.passcodeService,
            biometricAuthenticationService: appContainer.biometricAuthenticationService
        )
    }
}


struct AppLockContentView: View {
    @State private var viewModel: AppLockViewModel

    init(
        appSettings: AppSettings,
        passcodeService: PasscodeService,
        biometricAuthenticationService: BiometricAuthenticationService
    ) {
        _viewModel = State(
            initialValue: AppLockViewModel(
                appSettings: appSettings,
                passcodeService: passcodeService,
                biometricAuthenticationService: biometricAuthenticationService
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isUnlocked {
                ContentView()
            } else if viewModel.isShowingPasscode {
                PasscodeInputView(
                    mode: .unlock,
                    onComplete: { passcode in
                        viewModel.verifyPasscode(passcode)
                    }
                )
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.authenticate()
        }
    }
}
