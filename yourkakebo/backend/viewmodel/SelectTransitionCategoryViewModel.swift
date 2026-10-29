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
    
    let usedExpenseIds: [UUID]
    let usedIncomeIds: [UUID]
    
    var transitionPeriod: TransitionPeriod
    
    var selectedCategory: CategoryModel? = nil
        
    init(categoryService: CategoryService, transitionService: TransitionService, usedExpenseIds: [UUID], usedIncomeIds: [UUID], transitionPeriod: TransitionPeriod) {
        self.categoryService = categoryService
        self.transitionService = transitionService
        self.usedExpenseIds = usedExpenseIds
        self.usedIncomeIds = usedIncomeIds
        self.transitionPeriod = transitionPeriod
    }
    
    func load(_ transitionPeriod: TransitionPeriod) throws {
        let categories = try categoryService.getAllCategoriesByTransitionType(transitionPeriod.type)
        
        let ids = transitionPeriod.type == .expense ? usedExpenseIds : usedIncomeIds
        
        categoriesData = categories.map { category in
            SelectTransitionCategoryData(
                category: category,
                isUsed: ids.contains(category.categoryId)
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
