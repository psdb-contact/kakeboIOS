//
//  CycleOptionType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/19.
//

import SwiftUI

enum CycleOptionType: Hashable {
    case daily
    case weekday
    case weekly(Int)
    case monthly(Int)
    case yearly

    var displayString: String {
        switch self {
        case .daily:
            return "毎日"

        case .weekday:
            return "平日"

        case .weekly(1):
            return "毎週"

        case .weekly(let interval):
            return "\(interval)週間"

        case .monthly(1):
            return "毎月"

        case .monthly(6):
            return "半年"

        case .monthly(let interval):
            return "\(interval)か月"

        case .yearly:
            return "毎年"
        }
    }
}
