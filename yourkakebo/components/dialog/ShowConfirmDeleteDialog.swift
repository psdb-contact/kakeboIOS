//
//  ShowConfirmDeleteDialog.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftUI

func showConfirmDeleteDialog(
    title: String,
    showSwitch: Bool = false,
    initialSwitchValue: Bool = false,
    additionalMessage: String = "",
    switchLabel: String = "次回以降表示しない",
    cancelText: String = "キャンセル",
    confirmText: String = "削除",
    onResult: @escaping (Bool, Bool?) -> Void
) {
    // SwiftUIではView側で.sheet / .alertを管理するため、
    // この関数は直接ダイアログを表示するのではなく、
    // ConfirmDeleteDialogを表示するためのデータを返す構成にする。
}

struct ConfirmDeleteDialog: View {
    let title: String
    let showSwitch: Bool
    let initialSwitchValue: Bool
    let additionalMessage: String
    let switchLabel: String
    let cancelText: String
    let confirmText: String

    let onResult: (Bool, Bool?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var switchValue: Bool

    init(
        title: String,
        showSwitch: Bool = false,
        initialSwitchValue: Bool = false,
        additionalMessage: String = "",
        switchLabel: String = "次回以降表示しない",
        cancelText: String = "キャンセル",
        confirmText: String = "削除",
        onResult: @escaping (Bool, Bool?) -> Void
    ) {
        self.title = title
        self.showSwitch = showSwitch
        self.initialSwitchValue = initialSwitchValue
        self.additionalMessage = additionalMessage
        self.switchLabel = switchLabel
        self.cancelText = cancelText
        self.confirmText = confirmText
        self.onResult = onResult

        _switchValue = State(initialValue: initialSwitchValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 16)

            Text("削除してもよろしいですか？")
                .multilineTextAlignment(.center)

            if !additionalMessage.isEmpty {
                Text(additionalMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
            }

            if showSwitch {
                HStack {
                    Text(switchLabel)

                    Spacer()

                    Toggle("", isOn: $switchValue)
                        .labelsHidden()
                }
                .padding(.top, 16)
            }

            Divider()
                .padding(.top, 20)

            HStack(spacing: 0) {
                Button {
                    onResult(false, nil)
                    dismiss()
                } label: {
                    Text(cancelText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }

                Divider()
                    .frame(height: 44)

                Button(role: .destructive) {
                    if showSwitch {
                        onResult(true, switchValue)
                    } else {
                        onResult(true, nil)
                    }

                    dismiss()
                } label: {
                    Text(confirmText)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
        }
        .padding(.top, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }
}
