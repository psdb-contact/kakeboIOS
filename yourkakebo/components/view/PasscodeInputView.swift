//
//  PasscodeInputView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import SwiftUI

struct PasscodeInputView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    enum Mode {
        case set
        case remove
        case unlock
    }
    
    let mode: Mode
    let onComplete: (String) ->  Result<Void, PasscodeError>
    
    @State private var passcode = ""
    @State private var confirmationCode = ""
    
    @State private var errorMessage: String?
    
    private let passcodeLength = 4
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
        
        Text(message)
            .foregroundStyle(.secondary)
        
        PasscodeDotsView(
            count: passcodeLength,
            filledCount: passcode.count
        )
        
        if let errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
        }
        
        NumberPadView { number in
            input(number)
        }
    }
    
    private var title: String {
        switch mode {
        case .set:
            return confirmationCode.isEmpty ? "パスコードを設定" : "パスコードを確認"
            
        case .remove:
            return "パスコードを入力"
        case .unlock:
             return "パスコードを入力"
        }
    }
    
    private var message: String {
        switch mode {
        case .set:
            return confirmationCode.isEmpty
            ? "4桁のパスコードを入力してください"
            : "もう一度入力してください"
            
        case .remove:
            return "現在のパスコードを入力してください"
        case .unlock:
            return "パスコードを入力してください"
        }
    }
    
    private func input(_ number: Int) {
        guard passcode.count < passcodeLength else {
            return
        }
        
        errorMessage = nil

        passcode.append(String(number))
        guard passcode.count == passcodeLength else {
            return
        }
        
        handleCompletedInput()
    }
    
    private func handleCompletedInput() {
        switch mode {

        case .set:
            handleSet()

        case .remove:
            handleRemove()
            
        case .unlock:
            handleUnlock()
        }
    }

    private func handleSet() {
        if confirmationCode.isEmpty {
            confirmationCode = passcode
            passcode = ""
            return
        }

        guard passcode == confirmationCode else {
            errorMessage = "パスコードが一致しません。"
            passcode = ""
            confirmationCode = ""
            return
        }

        handleComplete()
    }

    private func handleRemove() {
        handleComplete()
    }
    
    private func handleUnlock() {
        handleComplete()
    }
    
    private func handleComplete() {
        switch onComplete(passcode) {
        case .success:
            dismiss()

        case .failure(let error):
            passcode = ""
            errorMessage = error.localizedDescription
        }
    }
}
