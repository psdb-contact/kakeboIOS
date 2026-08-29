import SwiftUI

struct ConfirmResetDialog: View {
    let title: String
    let additionalMessage: String
    let cancelText: String
    let confirmText: String
    let onResult: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        additionalMessage: String = "",
        cancelText: String = "キャンセル",
        confirmText: String = "初期化",
        onResult: @escaping (Bool) -> Void
    ) {
        self.title = title
        self.additionalMessage = additionalMessage
        self.cancelText = cancelText
        self.confirmText = confirmText
        self.onResult = onResult
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 16)

            Text("全データを初期化してもよろしいですか？")
                .multilineTextAlignment(.center)

            Text(
                additionalMessage.isEmpty
                    ? "※この操作は取り消せません"
                    : additionalMessage
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 16)

            Divider()
                .padding(.top, 20)

            HStack(spacing: 0) {
                Button {
                    onResult(false)
                    dismiss()
                } label: {
                    Text(cancelText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }

                Divider()
                    .frame(height: 44)

                Button(role: .destructive) {
                    onResult(true)
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
