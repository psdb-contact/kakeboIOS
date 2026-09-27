//
//  SelectionView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/27.
//

import SwiftUI

struct SelectionView<T>: View where T: CaseIterable & Hashable {

    let title: String
    @Binding var selection: T
    let displayName: (T) -> String
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button {
                        selection = option
                        dismiss()
                    } label: {
                        HStack {
                            Text(displayName(option))

                            Spacer()

                            if selection == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.container)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
