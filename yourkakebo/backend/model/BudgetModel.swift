//
//  BudgetModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@Model
final class BudgetModel {
    @Attribute(.unique) var budgetId: UUID
    var amount: Int
    var startMonth: Date
    var endMonth: Date
    var category: CategoryModel
    
    init(
        budgetId: UUID = UUID(),
        category: CategoryModel,
        amount: Int,
        startMonth: Date,
        endMonth: Date
    ) {
        self.budgetId = budgetId
        self.category = category
        self.amount = amount
        self.startMonth = startMonth
        self.endMonth = endMonth
    }
    
    static let  noExpirationDate = Date(timeIntervalSince1970: 253402214400)
}
