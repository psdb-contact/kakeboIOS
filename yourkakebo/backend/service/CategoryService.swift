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
    private let transitionRepository: TransitionRepository
    private let fixedTransitionRepsisotory: FixedTransitionRepository

    init(
        modelContext: ModelContext,
        categoryRepository: CategoryRepository,
        transitionRepository: TransitionRepository,
        fixedTransitionRepository: FixedTransitionRepository
    ) {
        self.modelContext = modelContext
        self.categoryRepository = categoryRepository
        self.transitionRepository = transitionRepository
        self.fixedTransitionRepsisotory = fixedTransitionRepository
    }

    func getAllCategories() throws -> [CategoryModel] {
        return try categoryRepository.getAllCategories()
    }
    
    func getAllCategoriesByTransitionType(_ transitionType: TransitionType) throws -> [CategoryModel] {
        return try categoryRepository.getAllCategoriesByTransitionType(transitionType)
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

    func deleteCategoryAndTransition(_ category: CategoryModel) throws {
        try modelContext.transaction {
            try transitionRepository.deleteTransitionByCategory(category)
            try fixedTransitionRepsisotory.deleteFixedTransitionByCategory(category)
            
            try categoryRepository.deleteCategory(category)
            
            try modelContext.save()
        }
    }
    
    func deleteCategoryAndSetOther(prev: CategoryModel, next: CategoryModel)  throws {
        try modelContext.transaction {
            try transitionRepository.setCategoryForTransitions(prev: prev, next: next)
            try fixedTransitionRepsisotory.setCategoryForFixedTransitions(prev: prev, next: next)
            
            try categoryRepository.deleteCategory(prev)
            
            try modelContext.save()
        }
    }
    
    func deleteCategoryAndSetNil(_ category: CategoryModel) throws {
        try modelContext.transaction {
            try transitionRepository.setCategoryForTransitions(prev: category, next: nil)
            try fixedTransitionRepsisotory.setCategoryForFixedTransitions(prev: category, next: nil)
            
            try categoryRepository.deleteCategory(category)
            
            try modelContext.save()
        }
    }
    
    func save() throws {
        try categoryRepository.save()
    }
}
