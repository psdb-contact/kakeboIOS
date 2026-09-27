//
//  Error.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/21.
//

import Foundation

enum EditCategoryError: LocalizedError {
    case emptyName
    case duplicateName

    var errorDescription: String? {
        switch self {
        case .emptyName:
            "カテゴリ名を入力してください"
        case .duplicateName:
            "同じ種類のカテゴリに同じ名前が既に存在します"
        }
    }
}

enum EditTransitionError: LocalizedError {
        case invalidAmount
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            "1円以上の金額を入力してください"
        }
    }
}

enum EditFixedTransitionError: LocalizedError {
    case emptyName
    case invalidAmount
    case invalidDateRange
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            "固定収支名を入力してください"
        case .invalidAmount:
            "1円以上の金額を入力してください"
        case .invalidDateRange:
            "終了日は開始日より前に設定できません"
        }
    }
}
