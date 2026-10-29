//
//  AmountInputAlert.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/26.
//

import SwiftUI

struct AmountInputAlert: ViewModifier {
    @Binding var isPresented: Bool
    
    let categoryName: String
    let onSubmit: (Int) -> Void
    
    
    @State private var amountInput = ""
    
    func body(content: Content) -> some View {
        content
            .alert(categoryName, isPresented: $isPresented) {
                TextField("金額", text: $amountInput)
                             .keyboardType(.numberPad)
                
                Button("キャンセル", role: .cancel) {
                    amountInput = ""
                }

                Button("登録") {
                    guard let amount = Int(amountInput),
                          amount >= 0 else {
                        return
                    }

                    onSubmit(amount)
                    amountInput = ""
                }
            }
    }
}
