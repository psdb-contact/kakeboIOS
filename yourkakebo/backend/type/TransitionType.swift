//
//  TransitionType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import Foundation

enum TransitionType:  String, Codable, CaseIterable {
    case expense
    case income
    
    var displayString: String {
          switch self {
          case .income:
              return "収入"
          case .expense:
              return "支出"
          }
      }
}

struct TransitionPeriod: Equatable {
    let type: TransitionType
    let date: Date
}

enum EditTransitionType: String {
    case add
    case overwrite
    
    var displayString: String {
        switch self {
        case .add:
            return "加算"
        case .overwrite:
            return "上書き"
        }
    }
}
