//
//  PasscodeDotsView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import SwiftUI

struct PasscodeDotsView: View {
    let count: Int
    let filledCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index < filledCount ? Color.primary : Color.clear)
                    .overlay {
                        Circle()
                            .stroke(
                                Color.secondary,
                                lineWidth: 1
                            )
                    }
                    .frame(width: 14, height: 14)
            }
        }
    }
}
