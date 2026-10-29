//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class AddTransitionViewModel {
    
    private let transitionService: TransitionService
    
    // MARK: - State
    
    let category: CategoryModel
    let transitionPeriod: TransitionPeriod
    
    var amountInput: String?
    
    var toast: ToastData?
    
    // MARK: - Init
    
    init(
        transitionService: TransitionService,
        category: CategoryModel,
        transitionPeriod: TransitionPeriod
    ) {
        self.transitionService = transitionService
        
        self.category = category
        self.transitionPeriod = transitionPeriod
    }
    
    
    // MARK: - Action
    
    func save() throws -> TransitionModel {
        let newTransition = TransitionModel(
            category: category,
            amount: Int(amountInput ?? "") ?? 0,
            transitionType: transitionPeriod.type,
            transitionDate: transitionPeriod.date,
            createdAt: Date(),
        )
        
        try transitionService.addTransition(
            newTransition
        )
        
        return newTransition
    }
}
