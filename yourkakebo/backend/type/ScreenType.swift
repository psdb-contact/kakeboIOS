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

enum ReportScreenType: String {
    case balance
    case budget

    var displayString: String {
        switch self {
            case .balance:
                return "収支"
            case .budget:
                return "予算"
        }
    }
}
