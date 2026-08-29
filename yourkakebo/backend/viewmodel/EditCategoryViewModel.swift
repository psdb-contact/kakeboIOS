//
//  EditCategoryViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditCategoryViewModel {
    private let categoryService: CategoryService
    
    
    var categoryName: String = ""
    var transitionType: TransitionType = .expense
    var colorHex: Int = 0xFFFFFF
    
    let category: CategoryModel?
    
    
    init(
        category: CategoryModel?,
        categoryService: CategoryService
    ) {
        self.category = category
        self.categoryService = categoryService
        
        if let category {
            categoryName = category.categoryName
            transitionType = category.transitionType
            colorHex = category.colorHex
        }
    }
    
    
    
    func save() throws {
        if let category {
            try categoryService.updateCategory(category)
        } else {
            try categoryService.addCategory(
                CategoryModel(
                    categoryName: categoryName,
                    transitionType: transitionType,
                    colorHex: colorHex
                )
            )
        }
    }
}
