//
//  TransitionType.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

enum TransitionType:  String, Codable {
    case income
    case expense
    
    var displayString: String {
          switch self {
          case .income:
              return "収入"
          case .expense:
              return "支出"
          }
      }
}
