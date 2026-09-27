//
//  AppThemeType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//
import SwiftUI

enum AppThemeType: String, CaseIterable, Hashable {
    case system
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .system:
            return "デバイスのモードを使用"
        case .dark:
            return "オン"
        case .light:
            return "オフ"
        }
    }
    
    var swiftUIThemeMode: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
