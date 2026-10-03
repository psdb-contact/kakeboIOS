//
//  PasscodeSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import SwiftUI

struct PasscodeSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackgroundColor.ignoresSafeArea()
            PasscodeSettingContentView(appSettings: appContainer.appSettings, passcodeService: appContainer.passcodeService, biometricAuthenticationService: appContainer.biometricAuthenticationService)
        }
    }
}

private struct PasscodeSettingContentView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    private let appSettings: AppSettings
    private let passcodeService: PasscodeService
    private let biometricAuthenticationService: BiometricAuthenticationService
    
    @State private var viewModel: PasscodeSettingViewModel
    
    init(appSettings: AppSettings, passcodeService: PasscodeService, biometricAuthenticationService: BiometricAuthenticationService) {
        self.appSettings = appSettings
        self.passcodeService = passcodeService
        self.biometricAuthenticationService = biometricAuthenticationService
        
        _viewModel = State(initialValue: PasscodeSettingViewModel(appSettings: appSettings, passcodeService: passcodeService, biometricAuthenticationService: biometricAuthenticationService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ScrollView {
            VStack(spacing: 12) {
                Toggle("パスコードロック",
                       isOn: Binding(
                        get: {
                            viewModel.isPasscodeSet
                        },
                        set: { isOn in
                            if isOn {
                                viewModel.showSetPasscode = true
                            } else {
                                viewModel.showRemovePasscode = true
                            }
                        }
                       )
                )
                if(viewModel.isPasscodeSet && viewModel.isBiometrySupported) {
                    Toggle("生体認証",
                           isOn: Binding(
                            get: {
                                viewModel.appSettings.isBiometricAuthenticationOn
                            },
                            set: { _ in
                                Task {
                                    await viewModel.toggleBiometricAuthentication()
                                }
                            }
                           )
                    )
                }
            }
            .navigationDestination(isPresented: $viewModel.showSetPasscode) {
                PasscodeInputView(
                    mode: .set,
                    onComplete: {passcode in
                        viewModel.setPasscode(passcode)
                    }
                )
            }
            .navigationDestination(isPresented: $viewModel.showRemovePasscode) {
                PasscodeInputView(
                    mode: .remove,
                    onComplete: { passcode in
                        viewModel.removePasscode(passcode)
                    }
                )
            }
        }
    }
}
