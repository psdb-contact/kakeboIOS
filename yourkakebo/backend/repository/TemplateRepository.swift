//
//  TemplateRepository.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@MainActor
final class TemplateRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getAllTemplates() throws -> [TemplateModel] {
        let descriptor = FetchDescriptor<TemplateModel>(
            sortBy: [
                SortDescriptor(\.sortOrder)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    func addTemplate(_ template: TemplateModel) throws {
        modelContext.insert(template)
        try modelContext.save()
    }

    func updateTemplate(_ template: TemplateModel) throws {
        try modelContext.save()
    }

    func reorderTemplates(_ templates: [TemplateModel]) throws {
        for (index, template) in templates.enumerated() {
            template.sortOrder = index
        }

        try modelContext.save()
    }

    func deleteTemplate(_ template: TemplateModel) throws {
        modelContext.delete(template)
        try modelContext.save()
    }

    func deleteAllTemplates() throws {
        let templates = try modelContext.fetch(
            FetchDescriptor<TemplateModel>()
        )

        for template in templates {
            modelContext.delete(template)
        }

        try modelContext.save()
    }

    func replaceAllTemplates(_ templates: [TemplateModel]) throws {
        try deleteAllTemplates()

        for template in templates {
            modelContext.insert(template)
        }

        try modelContext.save()
    }
    
    func save() throws {
        try modelContext.save()
    }
}
