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
    var category: CategoryModel?
    var amount: Int
    var startMonth: Date
    var endMonth: Date
    
    init(
        budgetId: UUID = UUID(),
        category: CategoryModel?,
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

struct BudgetBackup: Encodable, Decodable {
    let budgetId: UUID
    let categoryId: UUID?
    let amount: Int
    let startMonth: Date
    let endMonth: Date
}

extension BudgetBackup {
    init(model: BudgetModel) {
        self.init(
            budgetId: model.budgetId,
            categoryId: model.category?.categoryId,
            amount: model.amount,
            startMonth: model.startMonth,
            endMonth: model.endMonth
        )
    }
}

func parseBudgets(_ section: CSVSection) throws -> [BudgetBackup] {
    let index = try makeHeaderIndex(
        section.header,
        expected: ["budgetId", "categoryId", "amount", "startMonth", "endMonth"]
    )
    
    return try section.rows.map { row in
        BudgetBackup(
            budgetId: try parseUUID(row[index["budgetId"]!]),
            categoryId: try parseOptionalUUID(row[index["categoryId"]!]),
            amount: try parseInt(row[index["amount"]!]),
            startMonth: try parseDate(row[index["startMonth"]!]),
            endMonth: try parseDate(row[index["endMonth"]!]))
    }
}
