//
//  Category.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@Model
final class CategoryModel: Hashable  {
    @Attribute(.unique) var categoryId: UUID
    var categoryName: String
    var transitionType: TransitionType
    var colorHex: Int
    var isSystem: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \BudgetModel.category)
    var budgets: [BudgetModel] = []
    
    @Relationship(
        deleteRule: .nullify,
        inverse: \TransitionModel.category
    )
    var transitions: [TransitionModel] = []
    
    @Relationship(
        deleteRule: .nullify,
        inverse: \FixedTransitionModel.category
    )
    var fixedTransitions: [FixedTransitionModel] = []
    
    @Relationship(inverse: \TemplateModel.category)
    var templates: [TemplateModel] = []

    init(
        categoryId: UUID = UUID(),
        categoryName: String,
        transitionType: TransitionType,
        colorHex: Int,
        isSystem: Bool = false,
        isTemplateUsed: Bool = false,
        sortOrder: Int = 0
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.transitionType = transitionType
        self.colorHex = colorHex
        self.isSystem = isSystem
        self.sortOrder = sortOrder
    }

    static let uncategorizedId = "_system_uncategorized"
}

enum CategoryResultType {
    case selected
    case uncategorized
    case cancelled
}

struct CategoryResult {
    let type: CategoryResultType
    let category: Category?

    init(selected category: Category) {
        self.type = .selected
        self.category = category
    }

    init(uncategorized: Void = ()) {
        self.type = .uncategorized
        self.category = nil
    }

    init(cancelled: Void = ()) {
        self.type = .cancelled
        self.category = nil
    }
}

struct CategoryBackup: Encodable, Decodable {
    let categoryId: UUID
    let categoryName: String
    let transitionType: TransitionType
    let colorHex: Int
    let isSystem: Bool
    let sortOrder: Int
}

extension CategoryBackup {
    init(model: CategoryModel) {
        self.init(
            categoryId: model.categoryId,
            categoryName: model.categoryName,
            transitionType: model.transitionType,
            colorHex: model.colorHex,
            isSystem: model.isSystem,
            sortOrder: model.sortOrder
        )
    }
}

func parseCategories(_ section: CSVSection) throws -> [CategoryBackup] {
    let index = try makeHeaderIndex(section.header, expected: [
        "categoryId", "categoryName", "transitionType", "colorHex", "isSystem", "sortOrder"
    ])
    
    return try section.rows.map { row in
            CategoryBackup(
                categoryId: try parseUUID(row[index["categoryId"]!]),
                categoryName: row[index["categoryName"]!],
                transitionType: try parseEnum(row[index["transitionType"]!], as: TransitionType.self),
                colorHex: try parseInt(row[index["colorHex"]!]),
                isSystem: try parseBool(row[index["isSystem"]!]),
                sortOrder: try parseInt(row[index["sortOrder"]!])
            )
    }
}
