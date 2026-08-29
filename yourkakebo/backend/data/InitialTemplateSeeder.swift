//
//  InitialTemplateSeeder.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import Foundation
import SwiftData

enum InitialTemplateSeeder {

    static func seedIfNeeded(
        settings: SettingModel,
        context: ModelContext
    ) {
        guard settings.isFirstLaunch else {
            return
        }

        do {
            let templates = try loadTemplates(
                context: context
            )

            for template in templates {
                context.insert(template)
            }

            try context.save()

        } catch {
            print("初期テンプレートの作成に失敗しました: \(error)")
        }
    }

    // MARK: - Private

    private static func loadTemplates(
        context: ModelContext
    ) throws -> [TemplateModel] {

        guard let url = Bundle.main.url(
            forResource: "templateSeeds",
            withExtension: "json"
        ) else {
            throw SeedError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        let seeds = try JSONDecoder().decode(
            [TemplateSeed].self,
            from: data
        )

        var templates: [TemplateModel] = []

        for seed in seeds {
            let categoryName = seed.categoryName

            let descriptor = FetchDescriptor<CategoryModel>(
                predicate: #Predicate {
                    $0.categoryName == categoryName
                }
            )

            guard let category = try context.fetch(
                descriptor
            ).first else {
                throw SeedError.categoryNotFound(
                    categoryName
                )
            }

            let template = TemplateModel(
                category: category,
                sortOrder: seed.sortOrder
            )

            templates.append(template)
        }

        return templates
    }

    // MARK: - Seed Model

    private struct TemplateSeed: Decodable {
        let categoryName: String
        let sortOrder: Int
    }

    // MARK: - Error

    private enum SeedError: LocalizedError {
        case fileNotFound
        case categoryNotFound(String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "templateSeeds.json が見つかりません"

            case .categoryNotFound(let categoryName):
                return "カテゴリ「\(categoryName)」が見つかりません"
            }
        }
    }
}
