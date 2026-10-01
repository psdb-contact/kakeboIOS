//
//  BackupService.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/28.
//
import Foundation
import SwiftData

@MainActor
final class BackupService {
    private let modelContext: ModelContext
    
    private let categoryRepository: CategoryRepository
    private let budgetRepository: BudgetRepository
    private let fixedTransitionRepository: FixedTransitionRepository
    private let templateRepository: TemplateRepository
    private let transitionRepository: TransitionRepository
    
    
    private var backupDirectoryURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("Backup", isDirectory: true)
    }

    private var backupFileURL: URL {
        backupDirectoryURL
            .appendingPathComponent("internalBackup.json")
    }
    
    init(
        modelContext: ModelContext,
        categoryRepository: CategoryRepository,
        budgetRepository: BudgetRepository,
        fixedTransitionRepository: FixedTransitionRepository,
        templateRepisitory: TemplateRepository,
        transitionRepository: TransitionRepository
    ) {
        self.modelContext = modelContext
        self.categoryRepository = categoryRepository
        self.budgetRepository = budgetRepository
        self.fixedTransitionRepository = fixedTransitionRepository
        self.templateRepository = templateRepisitory
        self.transitionRepository = transitionRepository
    }
    
    func importExternalBackup(_ data: Data) throws {
        let csv = try decodeCSV(data)
        
        let backup = try parseBackup(csv)
        
        try modelContext.transaction {
            try deleteAll()
            
            try restoreCategories(backup.categories)
            try restoreTransitions(backup.transitions)
            try restoreFixedTransitions(backup.fixedTransitions)
            try restoreBudgets(backup.budgets)
            try restoreTemplates(backup.templates)
            
            try modelContext.save()
        }
    }
    
    func exportExternalBackup() throws -> Data {
        var csv = ""
        
        csv += try makeCategorySection()
        csv += try makeTransitionSection()
        csv += try makeFixedTransitionSection()
        csv += try makeBudgetSection()
        csv += try makeTemplateSection()
        
        var data = Data([0xEF, 0xBB, 0xBF])
        data.append(contentsOf: csv.utf8)
        
        return data
    }
    
    
    private func save(_ data: Data) throws {

        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: backupDirectoryURL.path) {
            try fileManager.createDirectory(
                at: backupDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        try data.write(
            to: backupFileURL,
            options: [.atomic]
        )
    }
    
    func importInternalBackup() throws  {
        let backup = try loadInternalBackup()
        
        try modelContext.transaction {
            try deleteAll()
            
            try restoreCategories(backup.categories)
            try restoreTransitions(backup.transitions)
            try restoreFixedTransitions(backup.fixedTransitions)
            try restoreBudgets(backup.budgets)
            try restoreTemplates(backup.templates)
            
            try modelContext.save()
        }
    }
    
    func exportInternalBackup() throws {
        let categories = try categoryRepository.getAllCategories()
        
        let transitions = try transitionRepository.getAllTransitions()
        let fixedTransitions = try fixedTransitionRepository.getAllFixedTransitions()
        let budgets = try budgetRepository.getAllBudgets()
        let templates = try templateRepository.getAllTemplates()
        
        let backup = BackupData(
            version: 1,
            createdAt: Date(),
            categories: categories.map(CategoryBackup.init),
            transitions: transitions.map(TransitionBackup.init),
            fixedTransitions: fixedTransitions.map(FixedTransitionBackup.init),
            budgets: budgets.map(BudgetBackup.init),
            templates: templates.map(TemplateBackup.init)
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(backup)
        
        try save(data)
    }
    
    private func deleteAll() throws {
        try transitionRepository.deleteAllTransitions()
        try fixedTransitionRepository.deleteAllFixedTransitions()
        try budgetRepository.deleteAllBudgets()
        try templateRepository.deleteAllTemplates()
        try categoryRepository.deleteAllCategories()
    }
    
    private func restoreCategories(
        _ backups: [CategoryBackup]
    ) throws {
        
        for item in backups {
            let category = CategoryModel(
                categoryId: item.categoryId,
                categoryName: item.categoryName,
                transitionType: item.transitionType,
                colorHex: item.colorHex,
                isSystem: item.isSystem,
                sortOrder: item.sortOrder
            )
            
            try categoryRepository.insertCategory(category)
        }
    }
    
    private func restoreTransitions(
        _ backups: [TransitionBackup]
    ) throws {
        
        let categories = try categoryRepository.getAllCategories()
        
        let categoryMap = Dictionary(
            uniqueKeysWithValues: categories.map {
                ($0.categoryId, $0)
            }
        )
        
        for item in backups {
            
            let category: CategoryModel?
            
            if let categoryId = item.categoryId {
                guard let found = categoryMap[categoryId] else {
                    throw BackupError.categoryNotFound(categoryId)
                }
                
                category = found
            } else {
                category = nil
            }
            
            let transition = TransitionModel(
                transitionId: item.transitionId,
                category: category,
                amount: item.amount,
                transitionType: item.transitionType,
                transitionDate: item.transitionDate,
                createdAt: item.createdAt,
                memo: item.memo
            )
            
            try transitionRepository.insertTransition(transition)
        }
    }
    
    private func restoreFixedTransitions(
        _ backups: [FixedTransitionBackup]
    ) throws {
        
        let categories = try categoryRepository.getAllCategories()
        
        let categoryMap = Dictionary(
            uniqueKeysWithValues: categories.map {
                ($0.categoryId, $0)
            }
        )
        
        for item in backups {
            
            let category: CategoryModel?
            
            if let categoryId = item.categoryId {
                guard let found = categoryMap[categoryId] else {
                    throw BackupError.categoryNotFound(categoryId)
                }
                
                category = found
            } else {
                category = nil
            }
            
            let fixedTransition = FixedTransitionModel(
                fixedTransitionId: item.fixedTransitionId,
                fixedTransitionName: item.fixedTransitionName,
                category: category,
                transitionType: item.transitionType,
                amount: item.amount,
                startDate: item.startDate,
                endDate: item.endDate,
                cycleType: item.cycleType,
                cycleInterval: item.cycleInterval,
                cycleValue: item.cycleValue,
                cycleHolidayType: item.cycleHolidayType,
                isActive: item.isActive
            )
            
            try fixedTransitionRepository.insertFixedTransition(fixedTransition)
        }
    }
    
    private func restoreBudgets(_ backups: [BudgetBackup]) throws {
        let categories = try categoryRepository.getAllCategories()
        
        let categoryMap = Dictionary(
            uniqueKeysWithValues: categories.map {
                ($0.categoryId, $0)
            }
        )
        
        for item in backups {
            let category: CategoryModel?
            
            if let categoryId = item.categoryId {
                guard let found = categoryMap[categoryId] else {
                    throw BackupError.categoryNotFound(categoryId)
                }
                
                category = found
            } else {
                category = nil
            }
            
            let budget = BudgetModel(budgetId: item.budgetId, category: category, amount: item.amount, startMonth: item.startMonth, endMonth: item.endMonth)
            
            try budgetRepository.insertBudget(budget)
        }
    }
    
    private func restoreTemplates(_ backups: [TemplateBackup]) throws {
        let categories = try categoryRepository.getAllCategories()
        
        let categoryMap = Dictionary(
            uniqueKeysWithValues: categories.map {
                ($0.categoryId, $0)
            }
        )
        
        for item in backups {
            let template = TemplateModel(templateId: item.templateId, category: categoryMap[item.categoryId]!, sortOrder: item.sortOrder)
            
            try templateRepository.insertTemplate(template)
        }
    }
    
    private func makeCategorySection() throws -> String {
        let categories = try self.categoryRepository.getAllCategories()
        
        var rows: [String] = []
        
        rows.append("# CategoryModel")
        rows.append("categoryId,categoryName,transitionType,colorHex,isSystem,sortOrder")
        
        for category in categories {
            rows.append([
                category.categoryId.uuidString,
                category.categoryName,
                category.transitionType.rawValue,
                String(category.colorHex),
                String(category.isSystem),
                String(category.sortOrder)
            ]
                .map(escapeCSV)
                .joined(separator: ",")
            )
        }
        
        rows.append("")
        return rows.joined(separator: "\n")
    }
    
    
    private func makeTransitionSection() throws -> String {
        let transitions = try self.transitionRepository.getAllTransitions()
        
        var rows: [String] = []
        
        rows.append("# TransitionModel")
        rows.append("transitionId,categoryId,amount,transitionType,transitionDate,createdAt,memo")
        
        for transition in transitions {
            rows.append([
                transition.transitionId.uuidString,
                transition.category?.categoryId.uuidString ?? "",
                String(transition.amount),
                transition.transitionType.rawValue,
                ISO8601DateFormatter().string(from: transition.transitionDate),
                ISO8601DateFormatter().string(from: transition.createdAt),
                transition.memo
            ]
                .map(escapeCSV)
                .joined(separator: ",")
            )
        }
        
        rows.append("")
        return rows.joined(separator: "\n")
    }
    
    private func makeFixedTransitionSection() throws -> String {
        let fixedTransitions = try self.fixedTransitionRepository.getAllFixedTransitions()
        
        var rows: [String] = []
        
        rows.append("# FixedTransitionModel")
        rows.append("fixedTransitionId,categoryId,fixedTransitionName,transitionType,amount,startDate,endDate,cycleType,cycleInterval,cycleValue,cycleHolidayType,isActive")
        
        let formatter = ISO8601DateFormatter()
        
        for fixedTransition in fixedTransitions {
            rows.append([
                fixedTransition.fixedTransitionId.uuidString,
                fixedTransition.category?.categoryId.uuidString ?? "",
                fixedTransition.fixedTransitionName,
                fixedTransition.transitionType.rawValue,
                String(fixedTransition.amount),
                formatter.string(from: fixedTransition.startDate),
                fixedTransition.endDate.map {
                    formatter.string(from: $0)
                } ?? "",
                fixedTransition.cycleType.rawValue,
                fixedTransition.cycleInterval.map(String.init) ?? "",
                fixedTransition.cycleValue.map(String.init) ?? "",
                fixedTransition.cycleHolidayType.rawValue,
                String(fixedTransition.isActive)
            ]
                .map(escapeCSV)
                .joined(separator: ",")
            )
            
        }
        
        rows.append("")
        return rows.joined(separator: "\n")
    }
    
    private func makeTemplateSection() throws -> String {
        let templates = try self.templateRepository.getAllTemplates()
        
        var rows: [String] = []
        
        rows.append("# TemplateModel")
        rows.append("templateId,categoryId,sortOrder")
        
        for template in templates {
            rows.append([
                template.templateId.uuidString,
                template.category.categoryId.uuidString,
                String(template.sortOrder)
            ]
                .map(escapeCSV)
                .joined(separator: ",")
            )
        }
        
        rows.append("")
        return rows.joined(separator: "\n")
    }
    
    private func makeBudgetSection() throws -> String {
        let budgets = try self.budgetRepository.getAllBudgets()
        
        var rows:[String] = []
        
        rows.append("# BudgetModel")
        rows.append("budgetId,categoryId,amount,startMonth,endMonth")
        
        let formatter = ISO8601DateFormatter()
        
        for budget in budgets {
            rows.append([
                budget.budgetId.uuidString,
                budget.category?.categoryId.uuidString ?? "",
                String(budget.amount),
                formatter.string(from: budget.startMonth),
                formatter.string(from: budget.endMonth)
            ]
                .map(escapeCSV)
                .joined(separator: ",")
            )
        }
        
        rows.append("")
        return rows.joined(separator: "\n")
    }
    
    private func decodeCSV(_ data: Data) throws  -> [CSVSection] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw BackupError.invalidFormat
        }
        
        let lines = text.components(separatedBy: .newlines)
        
        var sections: [CSVSection] = []
        
        var currentSectionName: String?
        var currentHeader: [String] = []
        var currentRows: [[String]] = []
        
        func appendCurrentSection() throws {
            guard let name = currentSectionName else {
                return
            }
            
            guard !currentHeader.isEmpty else {
                throw BackupError.invalidHeader
            }
            
            sections.append(
                CSVSection(
                    name: name,
                    header: currentHeader,
                    rows: currentRows
                )
            )
        }
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.isEmpty {
                continue
            }
            
            if trimmed.hasPrefix("# ") {
                try appendCurrentSection()
                
                currentSectionName = String(
                    trimmed.dropFirst(2)
                )
                
                currentHeader = []
                currentRows = []
                
                continue
            }
            
            let values = parseCSVLine(line)
            
            if currentHeader.isEmpty {
                currentHeader = values
            } else {
                currentRows.append(values)
            }
        }
        
        try appendCurrentSection()
        
        return sections
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var current = ""
        var insideQuotes = false
        
        var index = line.startIndex
        
        while index < line.endIndex {
            let character = line[index]
            
            if character ==  "\"" {
                let nextIndex = line.index(after: index)
                
                if insideQuotes, nextIndex < line.endIndex, line[nextIndex] == "\"" {
                    current.append("\"")
                    index = nextIndex
                } else {
                    insideQuotes.toggle()
                }
            } else if character == "," && !insideQuotes {
                values.append(current)
                current = ""
            } else {
                current.append(character)
            }
            
            index = line.index(after: index)
        }
        
        values.append(current)
        
        return values
    }
    
    private func parseBackup(_ sections: [CSVSection]) throws -> BackupData {
        guard let categorySection = sections.first(
            where: {$0.name == "CategoryModel"}
        ) else {
            throw BackupError.invalidFormat
        }
        
        guard let transitionSection = sections.first(
            where: { $0.name == "TransitionModel" }
        ) else {
            throw BackupError.invalidFormat
        }
        
        guard let fixedTransitionSection = sections.first(
            where: { $0.name == "FixedTransitionModel" }
        ) else {
            throw BackupError.invalidFormat
        }
        
        guard let budgetSection = sections.first(
            where: { $0.name == "BudgetModel" }
        ) else {
            throw BackupError.invalidFormat
        }
        
        guard let templateSection = sections.first(
            where: { $0.name == "TemplateModel" }
        ) else {
            throw BackupError.invalidFormat
        }
        
        return BackupData(
            version: 1,
            createdAt: Date(),
            categories: try parseCategories(categorySection),
            transitions: try parseTransitions(transitionSection),
            fixedTransitions: try parseFixedTransitions(
                fixedTransitionSection
            ),
            budgets: try parseBudgets(budgetSection),
            templates: try parseTemplates(templateSection)
        )
    }
    
    private func escapeCSV(_ value: String) -> String {
        
        let escaped = value.replacingOccurrences(
            of: "\"",
            with: "\"\""
        )
        
        if escaped.contains(",") ||
            escaped.contains("\"") ||
            escaped.contains("\n") ||
            escaped.contains("\r") {
            
            return "\"\(escaped)\""
        }
        
        return escaped
    }
    
    private func loadInternalBackup() throws -> BackupData {
        let data = try Data(contentsOf: backupFileURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(
            BackupData.self,
            from: data
        )
    }
    
    private struct BackupData: Encodable, Decodable {
        let version: Int
        let createdAt: Date
        
        let categories: [CategoryBackup]
        let transitions: [TransitionBackup]
        let fixedTransitions: [FixedTransitionBackup]
        let budgets: [BudgetBackup]
        let templates: [TemplateBackup]
    }
}

struct CSVSection {
    let name: String
    let header: [String]
    let rows: [[String]]
}

func makeHeaderIndex(_ header: [String], expected: [String]) throws -> [String: Int] {
    var result: [String: Int] = [:]
    
    for name in expected {
        guard let index = header.firstIndex(of:name) else {
            throw BackupError.invalidHeader
        }
        
        result[name] = index
    }
    
    return result
}

func parseUUID(_ value: String) throws -> UUID {
    
    guard let uuid = UUID(uuidString: value) else {
        throw BackupError.invalidUUID(value)
    }
    
    return uuid
}

func parseOptionalUUID(_ value: String) throws -> UUID? {
    guard !value.isEmpty else {
        return nil
    }
    
    return try parseUUID(value)
}

func parseInt(_ value: String) throws -> Int {
    
    guard let number = Int(value) else {
        throw BackupError.invalidInteger(value)
    }
    
    return number
}

func parseOptionalInt(_ value: String) throws -> Int? {
    guard !value.isEmpty else {
        return nil
    }
    
    return try parseInt(value)
}

func parseBool(_ value: String) throws -> Bool {
    
    switch value {
    case "true":
        return true
        
    case "false":
        return false
        
    default:
        throw BackupError.invalidBoolean(value)
    }
}

func parseDate(_ value: String) throws -> Date {
    
    let dateFormatter = ISO8601DateFormatter()
    
    guard let date = dateFormatter.date(
        from: value
    ) else {
        throw BackupError.invalidDate(value)
    }
    
    return date
}

func parseOptionalDate(
    _ value: String
) throws -> Date? {
    
    guard !value.isEmpty else {
        return nil
    }
    
    return try parseDate(value)
}

func parseEnum<T>(
    _ value: String,
    as type: T.Type
) throws -> T
where T: RawRepresentable, T.RawValue == String {
    
    guard let result = T(rawValue: value) else {
        throw BackupError.invalidEnumValue(
            type: String(describing: T.self),
            value: value
        )
    }
    
    return result
}
