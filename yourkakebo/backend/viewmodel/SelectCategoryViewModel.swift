//
//  CategorySelectViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class SelectCategoryViewModel {
    private let categoryService: CategoryService
    private let transitionService: TransitionService
    var categoriesData: [SelectCategoryData] = []
    
    init(categoryService: CategoryService, transitionService: TransitionService) {
        self.categoryService = categoryService
        self.transitionService = transitionService
    }
    
    func load(usedCategories: [CategoryModel]) throws {
        let categories = try categoryService.getAllCategories()
        
        categoriesData = categories.map { category in
            SelectCategoryData(
                category: category,
                isUsed: usedCategories.contains {
                    $0.categoryId == category.categoryId
                }
            )
        }
    }
    
    func save(transition: TransitionModel) throws {
        try transitionService.addTransition(transition)
    }
}

struct SelectCategoryData: Identifiable {
    let id = UUID()
    
    let category: CategoryModel
    let isUsed: Bool
}
