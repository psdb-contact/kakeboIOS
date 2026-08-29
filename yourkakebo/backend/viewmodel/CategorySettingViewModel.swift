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

    func deleteCategory() throws {
        guard let category = categoryToDelete else {
            return
        }

        try categoryService.deleteCategory(category)

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
