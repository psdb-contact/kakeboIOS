//
//  ToggleNavigation.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/01.
//

import SwiftUI

struct IconToggle<Item: Hashable>: View {
    
    struct ToggleItem {
        let icon: String
        let value: Item
    }
    
    let items: [ToggleItem]
    let selection: Item
    let onSelectionChanged:(Item) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.value) {
                item in
                
                let isSelected = selection == item.value
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onSelectionChanged(item.value)
                    }
                } label: {
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(
                            isSelected
                            ? .primary
                            : .secondary
                        )
                        .frame(
                            width: 44,
                            height: 36
                        )
                        .modifier(
                            ToggleGlsssEffectModifier(
                                isSelected: isSelected
                            )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .modifier(GlassEffectModifier())
    }
}

struct TextToggle<Item: Hashable>: View {

    struct ToggleItem {
        let title: String
        let value: Item

        init(
            title: String,
            value: Item
        ) {
            self.title = title
            self.value = value
        }
    }

    let items: [ToggleItem]
    let selection: Item
    let onSelectionChanged: (Item) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.value) { item in
                let isSelected = selection == item.value

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onSelectionChanged(item.value)
                    }
                } label: {
                    Text(item.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(
                            isSelected
                                ? .primary
                                : .secondary
                        )
                        .frame(
                            minWidth: 44,
                        )
                        .frame(height: 36)
                        .modifier(
                            ToggleGlsssEffectModifier(
                                isSelected: isSelected
                            )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .modifier(GlassEffectModifier())
    }
}
