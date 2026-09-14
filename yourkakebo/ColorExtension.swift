//
//  ColorExtension.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/28.
//

import SwiftUI

extension Color {
    static let accentColor = Color("AccentColor")
    static let appIconColor = Color("AppIcon")
    static let containerColor = Color("Container")
    static let inputContainerColor = Color("InputContainer")
    static let secondBackgroundColor = Color("SecondBackgroundColor")
    static let iconColor = Color("IconColor")
    static let modalSheetBackgroundColor = Color("ModalSheetBackground")
    
    init(hex: Int) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255

        self.init(
            red: red,
            green: green,
            blue: blue,
            opacity: 1
        )
    }
}

enum CategoryColors {
    static let all: [Int] = [
        0xFF6B6B, // Red
        0xFF8E53, // Orange
        0xFFB347, // Amber
        0xFFD93D, // Yellow
        0xC6E377, // Lime
        0x7ED957, // Green

        0x38D39F, // Mint
        0x2DD4BF, // Teal
        0x36CFC9, // Aqua
        0x4FC3F7, // Sky
        0x5AA9FF, // Blue
        0x7C83FD, // Indigo

        0x9B7EFD, // Purple
        0xB388FF, // Lavender
        0xD66BFF, // Violet
        0xFF6FD8, // Pink
        0xFF85A2, // Rose
        0xF28B82, // Coral

        0xC97C5D, // Brown
        0xD4A373, // Sand
        0x8BC34A, // Olive
        0x00C2A8, // Turquoise
        0x00B8D9, // Cyan
        0x5E60CE  // Deep Indigo
    ]
}
