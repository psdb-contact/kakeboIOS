//
//  CycleType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

enum CycleType: String, Codable {
    case daily
    case weekday
    case weekly
    case monthly
    case yearly

    var displayString: String {
        switch self {
        case .daily:
            return "毎日"
        case .weekday:
            return "平日"
        case .weekly:
            return "毎週"
        case .monthly:
            return "毎月"
        case .yearly:
            return "毎年"
        }
    }
}
