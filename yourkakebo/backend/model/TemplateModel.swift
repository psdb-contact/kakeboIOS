//
//  TemplateModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@Model
final class TemplateModel {
    @Attribute(.unique) var templateId: UUID
    var category: CategoryModel
    var sortOrder: Int

    init(
        templateId: UUID = UUID(),
        category: CategoryModel,
        sortOrder: Int = 0
    ) {
        self.templateId = templateId
        self.category = category
        self.sortOrder = sortOrder
    }
}
