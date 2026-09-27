//
//  AppContainer.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/16.
//

import SwiftData
import Observation

@Observable
final class AppContainer {
    let appSettings: AppSettings
    
    let categoryService: CategoryService
    let transitionService: TransitionService
    let budgetService: BudgetService
    let templateService: TemplateService
    let fixedTransitionService: FixedTransitionService
    
    init(modelContext: ModelContext) {
        self.appSettings = AppSettings()
        
        let categoryRepository = CategoryRepository(
            modelContext: modelContext
        )
        
        let transitionRepository = TransitionRepository(
            modelContext: modelContext
        )
        
        let budgetRepository = BudgetRepository(
            modelContext: modelContext
        )
        
        let templateRepository = TemplateRepository(
            modelContext: modelContext
        )
        
        let fixedTransitionRepository = FixedTransitionRepository(
            modelContext: modelContext
        )
        
        self.categoryService = CategoryService(
            modelContext: modelContext,
            categoryRepository: categoryRepository,
            transitionRepository: transitionRepository,
            fixedTransitionRepository: fixedTransitionRepository
        )
        
        self.transitionService = TransitionService(
            modelContext: modelContext,
            transitionRepository: transitionRepository
        )
        
        self.budgetService = BudgetService(
            modelContext: modelContext,
            budgetRepository: budgetRepository
        )
        
        self.templateService = TemplateService(
            modelContext: modelContext,
            templateRepository: templateRepository
        )
        
        self.fixedTransitionService = FixedTransitionService(
            modelContext: modelContext,
            fixedTransitionRepository: fixedTransitionRepository
        )
    }
}
