//
//  CustomSeparator.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/30.
//

import SwiftUI

struct TitleSeparator: View {
    let title: String
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.leading, 8)
            Divider()
        }
    }
}
