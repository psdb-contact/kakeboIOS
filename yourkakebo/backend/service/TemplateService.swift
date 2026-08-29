import SwiftData
import Foundation

final class TemplateService {
    private let modelContext: ModelContext
    private let templateRepository: TemplateRepository

    init(
        modelContext: ModelContext,
        templateRepository: TemplateRepository,
    ) {
        self.modelContext = modelContext
        self.templateRepository = templateRepository
    }

    func getAllTemplates() throws -> [TemplateModel] {
        try templateRepository.getAllTemplates()
    }

    func addTemplate(_ template: TemplateModel) throws {
        try modelContext.transaction {
            try templateRepository.addTemplate(template)
        }
    }

    func updateTemplate(_ template: TemplateModel) throws {
        try templateRepository.updateTemplate(template)
    }

    func reorderTemplates(_ templates: [TemplateModel]) throws {
        try modelContext.transaction {
            try templateRepository.reorderTemplates(templates)
        }
    }

    func deleteTemplate(_ template: TemplateModel) throws {
        try modelContext.transaction {
            try templateRepository.deleteTemplate(template)
        }
    }
    
    func save() throws {
        try templateRepository.save()
    }
}
