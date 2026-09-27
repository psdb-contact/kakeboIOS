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
final class SelectTemplateCategoryViewModel {
    private let categoryService: CategoryService
    private let templateService: TemplateService
    
    let usedCategories: [CategoryModel]
    var categoriesData: [SelectTemplateCategoryData] = []
    
    let transitionType: TransitionType
    
    init(categoryService: CategoryService, templateService: TemplateService, usedCategories: [CategoryModel], transitionType: TransitionType) {
        self.categoryService = categoryService
        self.templateService = templateService
        
        self.usedCategories = usedCategories
        self.transitionType = transitionType
    }
    
    func load() throws {
        let categories = try categoryService.getAllCategoriesByTransitionType(transitionType)
        
        categoriesData = categories.map { category in
            SelectTemplateCategoryData(
                category: category,
                isUsed: usedCategories.contains {
                    $0.categoryId == category.categoryId
                }
            )
        }
    }
    
    func save(template: TemplateModel) throws {
        try templateService.addTemplate(template)
    }
}

struct SelectTemplateCategoryData: Identifiable {
    let id = UUID()
    
    let category: CategoryModel
    let isUsed: Bool
}
