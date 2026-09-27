//
//  EditCategoryViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditCategoryViewModel {
    private let categoryService: CategoryService
    
    private var categories: [CategoryModel] = []
    
    var categoryName: String = ""
    var transitionType: TransitionType = .expense
    var colorHex: Int? = nil
    
    let category: CategoryModel?
    
    var toast: ToastData?
    
    init(
        category: CategoryModel?,
        categoryService: CategoryService,
        transitionType: TransitionType
    ) {
        self.category = category
        self.categoryService = categoryService
        self.transitionType = transitionType
        
        if let category {
            categoryName = category.categoryName
            colorHex = category.colorHex
        }
    }
    
    func load() throws {
        categories = try categoryService.getAllCategories()
        
        colorHex = defaultColorHex(from: categories)
    }
    
    func save() throws {
        let name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw EditCategoryError.emptyName
        }
        
        let isDuplicate = categories.contains {
            $0.transitionType == transitionType &&
            $0.categoryName == name
        }
        guard !isDuplicate else {
            throw EditCategoryError.duplicateName
        }
            
        
        if let category {
            category.categoryName = categoryName
            category.transitionType = transitionType
            category.colorHex = colorHex!
            
            try categoryService.updateCategory(category)
        } else {
            try categoryService.addCategory(
                CategoryModel(
                    categoryName: categoryName,
                    transitionType: transitionType,
                    colorHex: colorHex!
                )
            )
        }
    }
    
    private func defaultColorHex(
        from categories: [CategoryModel]
    ) -> Int {
        let colorUsage = categories.reduce(into: [Int: Int]()) {
            $0[$1.colorHex, default: 0] += 1
        }
        
        return CategoryColors.all.min {
            colorUsage[$0, default: 0] < colorUsage[$1, default: 0]
        } ?? CategoryColors.all[0]
    }
}
