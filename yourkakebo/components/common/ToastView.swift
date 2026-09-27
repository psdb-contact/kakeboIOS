import SwiftUI

struct ToastData: Equatable {
    let message: String
    let isError: Bool

    static func success(_ message: String) -> Self {
        Self(
            message: message,
            isError: false
        )
    }

    static func error(_ message: String) -> Self {
        Self(
            message: message,
            isError: true
        )
    }
}

struct ToastView: View {

    let toast: ToastData

    var body: some View {
        HStack(spacing: 8) {
            Image(
                systemName: toast.isError
                    ? "xmark"
                    : "checkmark"
            )
            .font(.system(size: 15, weight: .semibold))

            Text(toast.message)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct ToastModifier: ViewModifier {

    @Binding var toast: ToastData?

    func body(content: Content) -> some View {
        content
            .overlay {
                if let toast {
                    ToastView(toast: toast)
                        .transition(
                            .opacity
                                .combined(
                                    with: .scale(scale: 0.95)
                                )
                        )
                }
            }
            .animation(
                .easeOut(duration: 0.2),
                value: toast
            )
            .task(id: toast) {
                guard toast != nil else {
                    return
                }

                try? await Task.sleep(
                    for: .seconds(1.2)
                )

                guard !Task.isCancelled else {
                    return
                }

                withAnimation(.easeIn(duration: 0.2)) {
                    toast = nil
                }
            }
    }
}

extension View {
    func toast(
        toast: Binding<ToastData?>
    ) -> some View {
        modifier(
            ToastModifier(toast: toast)
        )
    }
}
