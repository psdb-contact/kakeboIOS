//
//  ReportPeriodType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/27.
//

import Foundation

enum ReportPeriodType: String, Codable, CaseIterable {
    case yearly
    case monthly
    
    var displayString: String {
        switch self {
        case .yearly:
            return "年別"
        case .monthly:
            return "月別"
        }
    }
}

struct ReportPeriod: Equatable {
    let type: ReportPeriodType
    let date: Date
}
