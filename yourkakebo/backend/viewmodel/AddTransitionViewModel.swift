//
//  AddTransitionViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/20.
//

import Foundation
import Observation

@Observable
final class AddTransitionViewModel {
    private let transitionService: TransitionService
    private let categoryService: CategoryService
    
    var selectedDate: Date
    
    let transitionType: TransitionType = .expense
    let category: CategoryModel? = nil
    let amount: Int? = nil
    
    init(transitionService: TransitionService, categoryService: CategoryService, selectedDate: Date) {
        self.transitionService = transitionService
        self.categoryService = categoryService
        self.selectedDate = selectedDate
    }
    
    
}
