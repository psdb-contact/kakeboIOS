import SwiftUI

struct PeriodNavigationBar: View {
    let formattedDate: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
            HStack(spacing: 0) {
                Button {
                    onPrevious()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22))
                        .frame(width: 44, height: 44)
                }

                Text(formattedDate)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 130)

                Button {
                    onNext()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22))
                        .frame(width: 44, height: 44)
                }
            }
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .modifier(GlassEffectModifier())
    }
}
