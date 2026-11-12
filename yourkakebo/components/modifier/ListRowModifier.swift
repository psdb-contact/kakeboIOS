//
//  ListRowModifier.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/11/13.
//

import SwiftUI

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(
                EdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 20,
                    trailing: 0
                )
            )
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                12
            }
            .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                dimensions.width - 12
            }
    }
}

extension View {
    func ListRowStyle() -> some View {
        modifier(ListRowModifier())
    }
}

struct ListRowComponentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
    }
}

extension View {
    func ListRowComponentStyle() -> some View {
        modifier(ListRowComponentModifier())
    }
}
