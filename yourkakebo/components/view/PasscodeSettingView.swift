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
        
        List {
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
        .listStyle(.insetGrouped)
       .scrollIndicators(.visible)
       .contentMargins(.top, 8, for: .scrollContent)
    }
}

#Preview {
    PreviewContent()
}

import SwiftData

@MainActor
private struct PreviewContent: View {
    
    private let container: ModelContainer
    private let appContainer: AppContainer
    
    init() {
        let container = try! ModelContainer(
            for:
                CategoryModel.self,
            TransitionModel.self,
            BudgetModel.self,
            TemplateModel.self,
            FixedTransitionModel.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )
        
        let context = container.mainContext
        
        PreviewSeeder.seed(
            context: context
        )
        
        self.container = container
        self.appContainer = AppContainer(
            modelContext: context
        )
    }
    
    var body: some View {
        NavigationStack{
            PasscodeSettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
