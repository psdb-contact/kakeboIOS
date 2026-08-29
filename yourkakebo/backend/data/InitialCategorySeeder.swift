import Foundation
import SwiftData

enum InitialCategorySeeder {

    static func seedIfNeeded(
        settings: SettingModel,
        context: ModelContext
    ) {
        guard settings.isFirstLaunch else {
            return
        }
         
        do {
            let categories = try loadCategories()

            for category in categories {
                context.insert(category)
            }

            try context.save()

        } catch {
            print("初期データの作成に失敗しました: \(error)")
        }
    }

    // MARK: - Private

    private static func loadCategories() throws -> [CategoryModel] {
        guard let url = Bundle.main.url(
            forResource: "categorySeeds",
            withExtension: "json"
        ) else {
            throw SeedError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        let seeds = try JSONDecoder().decode(
            [CategorySeed].self,
            from: data
        )

        return seeds.map {
            CategoryModel(
                categoryName: $0.categoryName,
                transitionType: $0.transitionType,
                colorHex: $0.colorHex,
                isSystem: $0.isSystem,
                isTemplateUsed: $0.isTemplateUsed,
                sortOrder: $0.sortOrder
            )
        }
    }

    private struct CategorySeed: Decodable {
        let categoryName: String
        let transitionType: TransitionType
        let colorHex: Int
        let isSystem: Bool
        let isTemplateUsed: Bool
        let sortOrder: Int
    }

    private enum SeedError: LocalizedError {
        case fileNotFound

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "categorySeeds.json が見つかりません"
            }
        }
    }
}
