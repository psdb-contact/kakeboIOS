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
    var categoriesData: [SelectTemplateCategoryData] = []
    
    init(categoryService: CategoryService, templateService: TemplateService) {
        self.categoryService = categoryService
        self.templateService = templateService
    }
    
    func load(usedCategories: [CategoryModel]) throws {
        let categories = try categoryService.getAllCategories()
        
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
