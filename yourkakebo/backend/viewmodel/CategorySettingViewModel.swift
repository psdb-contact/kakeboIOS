import Foundation
import Observation
import SwiftUI

@Observable
final class CategorySettingViewModel {
    private let categoryService: CategoryService
    
    var transitionType: TransitionType = .expense
    var showingAddCategory = false

    var categoryToEdit: CategoryModel?
    var categoryToDelete: CategoryModel?
    var currentCategory: CategoryModel?

    
    init(categoryService: CategoryService) {
        self.categoryService = categoryService
    }
    
    func moveCategory(
        from source: IndexSet,
        to destination: Int,
        categories: [CategoryModel]
    ) throws {
        var reordered = categories
        
        reordered.move(
            fromOffsets: source,
            toOffset: destination
        )
        
        for (index, category) in reordered.enumerated() {
            category.sortOrder = index
        }
        
        try categoryService.save()
    }
    
    func deleteCategoryAndTransition() throws {
        guard let category = categoryToDelete else {
            return
        }
        
        try categoryService.deleteCategoryAndTransition(category)
        
        categoryToDelete = nil
    }
    
    func deleteCategoryAndSetOther(_ next: CategoryModel) throws {
        guard let category = currentCategory else {
            return
        }
        try categoryService.deleteCategoryAndSetOther(prev: category, next: next)
        
        categoryToDelete = nil
    }
    
    func deleteCategoryAndSetNil() throws {
        guard let category = categoryToDelete else {
            return
        }
        try categoryService.deleteCategoryAndSetNil(category)
        
        categoryToDelete = nil
    }
    
    func selectCategoryForEditing(
        _ category: CategoryModel
    ) {
        categoryToEdit = category
    }
    
    func selectCategoryForDeletion(
        _ category: CategoryModel
    ) {
        categoryToDelete = category
    }
    
    func cancelDelete() {
        categoryToDelete = nil
    }
}
