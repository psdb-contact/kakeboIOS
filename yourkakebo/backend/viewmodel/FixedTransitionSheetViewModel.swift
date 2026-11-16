//
//  FixedTransitionSheetViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import Foundation
import Observation

@Observable
final class FixedTransitionDetailsSheetViewModel {
    private let fixedTransitionService: FixedTransitionService
        
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var editingDate: Date? 
    
    var totalIncome: Int = 0
    var totalExpense: Int = 0
    
    var incomes: [TransitionModel] = []
    var expenses: [TransitionModel] = []
    
    var fixedIncomes: [FixedTransitionModel] = []
    var fixedExpenses :[FixedTransitionModel] = []
 

    init(fixedTransitionService: FixedTransitionService, selectedDate: Date) {
        self.fixedTransitionService = fixedTransitionService
        self.selectedDate = selectedDate
    }
    
    func load() throws {
        
        let fixedTransitionList = try fixedTransitionService.getAllFixedTransitions()
 
        let filteredFixedTransitions = fixedTransitionList.filter {
            $0.occurs(on: selectedDate)
        }

        for item in filteredFixedTransitions {
            if(item.transitionType == .expense) {
                fixedExpenses.append(item)
            } else {
                fixedIncomes.append(item)
            }
        }
    }
    
    func moveDate(by value: Int) {
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: selectedDate
        ) ?? selectedDate
        
        try? load()
    }
}
