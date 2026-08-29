import SwiftUI

struct YearNavigationBar: View {
    let formattedDate: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
            HStack(spacing: 0) {
                Button {
                    onPrevious()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                }

                Text(formattedDate)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        Color(
                            red: 0.133,
                            green: 0.133,
                            blue: 0.133
                        )
                    )
                    .frame(width: 160)

                Button {
                    onNext()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                }
            }
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .modifier(GlassEffectModifier())
    }
}
