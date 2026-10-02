//
//  CommonType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

enum Weekday: Int, CaseIterable, Hashable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var displayName: String {
        switch self {
            case .sunday:
                return "日曜"
            case.monday:
                return "月曜"
            case .tuesday:
                return "火曜"
            case .wednesday:
                return "水曜"
            case .thursday:
                return "木曜"
            case .friday:
                return "金曜"
            case .saturday:
                return "土曜"
        }
    }
    
    var displayShortName: String {
        switch self {
            case .sunday:
                return "日"
            case.monday:
                return "月"
            case .tuesday:
                return "火"
            case .wednesday:
                return "水"
            case .thursday:
                return "木"
            case .friday:
                return "金"
            case .saturday:
                return "土"
        }
    }
}

extension Set where Element == Weekday {
    var displayText: String {
        if self == Set(Weekday.allCases) {
                return "毎日"
        }
        
        if self == [.monday, .tuesday, .wednesday, .thursday, .friday] {
                return "平日"
        }
        
        if self == [.saturday, .sunday] {
                return "休日"
        }
        
        return Weekday.allCases.filter { self.contains($0) }
            .map(\.displayShortName)
            .joined(separator: "、")
    }
}
