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

enum BackupError: LocalizedError {
    case invalidFormat
    case invalidHeader
    case invalidUUID(String)
    case invalidInteger(String)
    case invalidDate(String)
    case invalidBoolean(String)

    case invalidEnumValue(type: String, value: String)

    case categoryNotFound(UUID)

    var errorDescription: String? {

        switch self {
        case .invalidFormat:
            return "バックアップファイルの形式が正しくありません。"

        case .invalidHeader:
            return "バックアップファイルのヘッダーが正しくありません。"

        case .invalidUUID(let value):
            return "UUIDが正しくありません: \(value)"

        case .invalidInteger(let value):
            return "数値が正しくありません: \(value)"

        case .invalidDate(let value):
            return "日付が正しくありません: \(value)"

        case .invalidBoolean(let value):
            return "真偽値が正しくありません: \(value)"

        case .invalidEnumValue(let type, let value):
            return "\(type) の値が正しくありません: \(value)"

        case .categoryNotFound(let id):
            return "指定されたカテゴリが見つかりません: \(id)"
        }
    }
}
