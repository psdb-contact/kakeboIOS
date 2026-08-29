//
//  CategoryService.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import Foundation
import SwiftData

final class CategoryService {
    private let modelContext: ModelContext
    private let categoryRepository: CategoryRepository

    init(
        modelContext: ModelContext,
        categoryRepository: CategoryRepository,
    ) {
        self.modelContext = modelContext
        self.categoryRepository = categoryRepository
    }

    func getAllCategories() throws -> [CategoryModel] {
        return try categoryRepository.getAllCategories()
    }

    func addCategory(_ category: CategoryModel) throws {
        try categoryRepository.addCategory(category)
    }

    func updateCategory(_ category: CategoryModel) throws {
        try categoryRepository.updateCategory(category)
    }

    func reorderCategories(_ categories: [CategoryModel]) throws {
        try modelContext.transaction {
            try categoryRepository.reorderCategories(categories)
        }
    }

    func deleteCategory(_ category: CategoryModel) throws {
        try categoryRepository.deleteCategory(category)
    }
    
    func save() throws {
        try categoryRepository.save()
    }
}
