//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class AddTransitionOnCalendarViewModel {
    
    private let transitionService: TransitionService
    private let categoryService: CategoryService
    
    var categories: [CategoryModel] = []
    
    // MARK: - State
    var showCategorySheet = false
    
    var category: CategoryModel? = nil  
    var editingCategory: CategoryModel? = nil
    
    var transitionType: TransitionType = .expense
    let selectedDate: Date
    
    var amountInput: String?
    
    var toast: ToastData?
    
    // MARK: - Init
    
    init(
        transitionService: TransitionService,
        categoryService: CategoryService,
        selectedDate: Date
    ) {
        self.transitionService = transitionService
        self.categoryService = categoryService
        
        self.selectedDate = selectedDate
    }
    
    func load() throws {
        categories = try categoryService.getAllCategories()
    }
    
    // MARK: - Action
    
    func save() throws -> TransitionModel {
        let amount = Int(amountInput ?? "") ?? 0
        return try transitionService.addOrEditTransition(amount: amount, transitionType: transitionType, category: category!, transitionDate: selectedDate)
    }
}
