//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditTransitionSheetViewModel {
    
    private let transitionService: TransitionService
    
    
    // MARK: - State
    var editType: EditTransitionType = .add {
        didSet {
            handleEditTypeChanged()
        }
    }
    
    var category: CategoryModel
    var transition: TransitionModel? = nil
    
    var transitionPeriod: TransitionPeriod
    var amountInput: String?
    
    var toast: ToastData?
    
    // MARK: - Init
    
    init(
        transitionService: TransitionService,
        transition: TransitionModel?,
        category: CategoryModel,
        transitionPeriod: TransitionPeriod
    ) {
        self.transitionService = transitionService
        
        self.transition = transition
        self.category = category
        self.transitionPeriod = transitionPeriod
    }
    
    private func handleEditTypeChanged() {
        switch editType {
        case .add:
            amountInput = nil
            break
        case .overwrite:
            amountInput = transition.map { String($0.amount) }
            break
        }
    }
    
    // MARK: - Action
    
    func save() throws -> TransitionModel {
        if transition != nil {
            var newAmount = 0
            if(editType == .add) {
                newAmount = transition!.amount + (Int(amountInput ?? "") ?? 0)
            } else {
                newAmount = Int(amountInput ?? "") ?? 0
            }
            
            try transitionService.editTransition(id: transition!.transitionId, amount: newAmount)
            
            return TransitionModel(
                category: category,
                amount: newAmount,
                transitionType: transition!.transitionType,
                transitionDate: transition!.transitionDate,
                createdAt: transition!.createdAt
            )
        } else {
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
}
