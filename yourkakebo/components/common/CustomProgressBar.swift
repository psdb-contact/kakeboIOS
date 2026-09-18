//
//  CustomProgressBar.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/17.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        GeometryReader {
                geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.gray.opacity(0.15))
                Capsule().fill(color).frame(width: geometry.size.width * min(progress, 1))
            }
        }
        .frame(height: 8)
    }
}
