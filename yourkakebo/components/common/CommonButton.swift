//
//  CommonButton.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/09.
//

import SwiftUI

struct SubmitButton: View {
    let action: () -> Void
    var tint: Color = .submitColor
    var size: CGFloat = 44
    var systemName: String = "checkmark"
    
    var body: some View {
        Button(action: action) {
            if #unavailable(iOS 26.0) {
                CheckIcon(color: Color.white)
                    .frame(width: size, height: size)
                    .background(Circle().fill(tint))
            } else {
                CheckIcon(color: Color.white)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .modifier(GlassButtonStyleModifier(tint: tint))
    }
}

struct CancelButton: View {
    let action: () -> Void
    var tint: Color = Color.white
    var size: CGFloat = 44
    var systemName: String = "xmark"
    
    var body: some View {
        Button(action: action) {
            if #unavailable(iOS 26.0) {
                CloseIcon()
                    .frame(width: size, height: size)
                    .background(Circle().fill(tint))
            } else {
                CloseIcon()
                    .foregroundColor(.primary)
            }
        }
        .modifier(GlassButtonStyleModifier(tint: tint))
    }
}

struct CloseKeyboardButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CloseIcon()
                .frame(width: 44, height: 44)
        }
        .modifier(GlassEffectModifier())
        .contentShape(.circle)
    }
}
