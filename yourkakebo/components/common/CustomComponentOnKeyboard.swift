//
//  CustomComponentOnKeyboard.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/17.
//

import SwiftUI

struct CloseComponentOnKeyboard: View {
        
    let closeAction: () -> Void

    var body: some View {
        HStack {
            Spacer()
            CloseKeyboardButton {
                _ = closeAction()
            }
        }
        .padding(.trailing, 8)
        .padding(.bottom, 8)
    }
}

struct CloseSaveComponentOnKeyboard: View {
    
    let closeAction: () -> Void
    let action: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Button {
                    closeAction()
                } label: {
                    CloseIcon()
                        .foregroundColor(.primary)
                        .frame(width: 64, height: 44)
                }
                Spacer()
                Button {
                    action()
                } label: {
                    Text("保存")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                }
                .padding(.trailing, 24)
            }
            .frame(minHeight: 48)
            .modifier(GlassEffectModifier())
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 8)
    }
}

