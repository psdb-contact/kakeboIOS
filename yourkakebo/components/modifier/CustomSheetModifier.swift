//
//  CustomSheetModifier.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/15.
//

import SwiftUI

struct CustomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    
    let height: CGFloat
    let sheetContent: () -> SheetContent
    
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        dismiss()
                    }
                
                VStack {
                    sheetContent()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .background(.background)
                        .offset(y: offset)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.move(edge: .bottom))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = max(0, value.translation.height)
                                }
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = 0
                                        }
                                    }
                                }
                        )
                }
                .animation(.easeOut(duration: 0.25), value: isPresented)
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
            offset = 0
        }
    }
}
