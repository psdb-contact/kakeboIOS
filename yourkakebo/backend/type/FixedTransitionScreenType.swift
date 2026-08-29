//
//  FixedTransitionScreenType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/18.
//

enum FixedTransitionScreenType: String {
case list
    case calendar
    
    var displayString: String {
        switch self {
        case .list:
            return "リスト"
        case .calendar:
            return "カレンダー"
        }
    }
}
