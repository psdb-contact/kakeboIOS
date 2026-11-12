//
//  GlassEffectModifier.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/20.
//
import SwiftUI

struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect()
        } else {
            content
        }
    }
}

struct ToggleGlsssEffectModifier: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(
                isSelected ? .regular : .identity
            )
        } else {
            content
        }
    }
}

struct GlassButtonStyleModifier: ViewModifier {
    let tint: Color

     func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            content
                .buttonStyle(.plain)
        }
    }
}

/*
      .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CancelButton(action :  {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                },
                         tint: .secondaryCancel
                )
                Spacer()
                SubmitButton(action: {
                    viewModel.isSaving = true
                    viewModel.editingDataId = viewModel.focusedDataId
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                    DispatchQueue.main.async {
                        viewModel.isSaving = false
                    }
                }, tint: Color.submitColor)
            }
        }
*/
