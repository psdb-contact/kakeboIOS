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

struct TemplateBackup: Encodable, Decodable {
    let templateId: UUID
    let categoryId: UUID
    let sortOrder: Int
}

extension TemplateBackup {
    init(model: TemplateModel) {
        self.init(templateId: model.templateId, categoryId: model.category.categoryId, sortOrder: model.sortOrder)
    }
}

func parseTemplates(_ section: CSVSection) throws -> [TemplateBackup] {
    let index = try makeHeaderIndex(
        section.header,
        expected: ["templateId", "categoryId", "sortOrder"]
    )
    
    return try section.rows.map {row in
        TemplateBackup(
            templateId: try parseUUID(row[index["templateId"]!]),
            categoryId: try parseUUID(row[index["categoryId"]!]),
            sortOrder: try parseInt(row[index["sortOrder"]!]))
    }
}
