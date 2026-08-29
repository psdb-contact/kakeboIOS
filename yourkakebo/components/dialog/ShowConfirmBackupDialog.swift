//
//  ShowConfirmBackupDialog.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

//
//  ShowConfirmResetDialog.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftUI

struct ConfirmBackupDialog: View {
    let title: String
    let mainMessage: String
    let caution: String
    let cancelText: String
    let confirmText: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)

            VStack(spacing: 16) {
                Text(mainMessage)
                    .multilineTextAlignment(.center)
                    .font(.body)

                Text(caution)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)

            Divider()
                .padding(.top, 20)

            HStack(spacing: 0) {
                Button(cancelText) {
                    onCancel()
                }
                .frame(maxWidth: .infinity)

                Divider()

                Button(confirmText) {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
            }
            .frame(height: 50)
        }
        .frame(maxWidth: 320)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

func showConfirmBackupDialog(
    title: String,
    mainMessage: String = "",
    caution: String = "",
    cancelText: String = "キャンセル",
    confirmText: String = "",
    onCancel: @escaping () -> Void,
    onConfirm: @escaping () -> Void
) -> some View {
    fatalError()
}
