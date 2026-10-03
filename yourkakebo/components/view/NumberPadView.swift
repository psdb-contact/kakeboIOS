//
//  NumberPadView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/02.
//

import SwiftUI

struct NumberPadView: View {
    let onNumber: (Int) -> Void
    private let numbers = [
    [1,2,3],
    [4,5,6],
    [7,8,9],
    [nil,0,nil]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<numbers.count, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(0..<3, id: \.self) { column in
                        if let number = numbers[row][column] {
                            Button {
                                    onNumber(number)
                            } label: {
                                Text("\(number)")
                                    .font(.title2)
                                    .frame(width: 72, height: 72)
                                    .background(Circle().fill(Color.secondary.opacity(0.15)))
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear
                                .frame(width: 72, height: 72)
                        }
                    }
                }
            }
        }
    }
}
