//
//  SelectionView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/27.
//

import SwiftUI

struct SelectionView<T>: View where T: CaseIterable & Hashable {

    let title: String
    let options: [T]
    @Binding var selection: T
    let displayString: (T) -> String
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                    dismiss()
                } label: {
                    HStack {
                        Text(displayString(option))

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
        .listStyle(.insetGrouped)
           .scrollIndicators(.visible)
           .contentMargins(.top, 8, for: .scrollContent)
        
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
