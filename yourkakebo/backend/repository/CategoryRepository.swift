
//
//  CategoryRepository.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@MainActor
final class CategoryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getAllCategories() throws -> [CategoryModel] {
        let descriptor = FetchDescriptor<CategoryModel>(
            sortBy: [
                SortDescriptor(\.sortOrder)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    func addCategory(_ category: CategoryModel) throws {
        let minSortOrder = try getMinSortOrder()

        category.sortOrder = minSortOrder - 1

        modelContext.insert(category)
        try modelContext.save()
    }

    func updateCategory(_ category: CategoryModel) throws {
        try modelContext.save()
    }

    func reorderCategories(_ categories: [CategoryModel]) throws {
        for (index, category) in categories.enumerated() {
            category.sortOrder = index
        }

        try modelContext.save()
    }

    func deleteCategory(_ category: CategoryModel) throws {
        modelContext.delete(category)
        try modelContext.save()
    }

    func deleteCategory(id: String) throws {
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { category in
                category.categoryId == id
            }
        )

        guard let category = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(category)
        try modelContext.save()
    }

    func replaceAllCategories(_ categories: [CategoryModel]) throws {
        try deleteAllCategories()

        for category in categories {
            modelContext.insert(category)
        }

        try modelContext.save()
    }

    func deleteAllCategories() throws {
        let categories = try modelContext.fetch(FetchDescriptor<CategoryModel>())

        for category in categories {
            modelContext.delete(category)
        }

        try modelContext.save()
    }

    func getMinSortOrder() throws -> Int {
        let categories = try modelContext.fetch(
            FetchDescriptor<CategoryModel>(
                sortBy: [
                    SortDescriptor(\.sortOrder)
                ]
            )
        )

        return categories.map(\.sortOrder).min() ?? 0
    }
    
    
    func save() throws {
        try modelContext.save()
    }
}
