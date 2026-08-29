//
//  Category.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@Model
final class CategoryModel {
    @Attribute(.unique) var categoryId: String
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
        categoryId: String = UUID().uuidString,
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
