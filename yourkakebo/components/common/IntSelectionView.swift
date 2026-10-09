//
//  IntSelectionView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/04.
//

import SwiftUI

struct IntSelectionView: View {
    let title: String
    let values: [Int]
    @Binding var selection: Int
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        ScrollView{
            VStack(spacing: 12) {
                ForEach(values, id: \.self) {option in
                    Button{
                        selection = option
                        dismiss()
                    } label: {
                        HStack {
                            Text(String(option))
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
                    .background( RoundedRectangle(cornerRadius: 12) .fill(Color.container) )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
