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
final class SelectTransitionCategoryViewModel {
    private let categoryService: CategoryService
    private let transitionService: TransitionService
    var categoriesData: [SelectTransitionCategoryData] = []
    
    let usedCategories: [CategoryModel]
    let transitionType: TransitionType
    
    init(categoryService: CategoryService, transitionService: TransitionService, usedCategories: [CategoryModel], transitionType: TransitionType) {
        self.categoryService = categoryService
        self.transitionService = transitionService
        self.usedCategories = usedCategories
        self.transitionType = transitionType
    }
    
    func load() throws {
        let categories = try categoryService.getAllCategoriesByTransitionType(transitionType)
        
        categoriesData = categories.map { category in
            SelectTransitionCategoryData(
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

struct SelectTransitionCategoryData: Identifiable {
    let id = UUID()
    
    let category: CategoryModel
    let isUsed: Bool
}
