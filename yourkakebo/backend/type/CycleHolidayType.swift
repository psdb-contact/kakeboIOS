//
//  CycleHolidayType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

enum CycleHolidayType:  String, Codable, CaseIterable  {
    case doNothing
    case before
    case after
    
    var displayString: String {
        switch self {
        case .doNothing:
            return "何もしない"
        case .before:
            return "開始日を直前の平日とする"
        case .after:
            return "開始日を直後の平日とする"
        }
    }
}
