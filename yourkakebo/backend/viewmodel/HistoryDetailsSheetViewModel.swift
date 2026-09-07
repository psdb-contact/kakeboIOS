//
//  FixedTransitionSheetViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import Foundation
import Observation

@Observable
final class HistoryDetailsSheetViewModel {
    private let transitionService: TransitionService
    private let fixedTransitionService: FixedTransitionService
        
    var selectedDate: Date = Date()
    
    var incomes: [TransitionModel] = []
    var expenses: [TransitionModel] = []
    
    var fixedIncomes: [FixedTransitionModel] = []
    var fixedExpenses :[FixedTransitionModel] = []
 

    init(transitionService: TransitionService, fixedTransitionService: FixedTransitionService, selectedDate: Date) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
        self.selectedDate = selectedDate
    }
    
    func load() throws {
        incomes = []
        expenses = []
        
        let transitionList = try transitionService.getAllTransitionsByDate(selectedDate)
        
        incomes = transitionList.filter { $0.transitionType == .income }
        expenses = transitionList.filter { $0.transitionType == .expense }
        
        let fixedTransitionList = try fixedTransitionService.getAllFixedTransitions()
 
        let calendar = Calendar.current
        let searchStart = calendar.date(
            byAdding: .day,
            value: -7,
            to: selectedDate
        )!
        
        let searchEnd = calendar.date(
            byAdding: .day,
            value: 7,
            to: selectedDate
        )!
        
        fixedIncomes = []
        fixedExpenses = []

        for item in fixedTransitionList {
            guard item.isActive else {
                continue
            }
            
            let occurrenceDates = item.occurrenceDates(
                searchStart: searchStart,
                searchEnd: searchEnd,
                calendar: calendar
            )
            
            if occurrenceDates.contains(where: {
                 calendar.isDate($0, inSameDayAs: selectedDate)
             }) {
                if(item.transitionType == .expense) {
                    fixedExpenses.append(item)
                } else {
                    fixedIncomes.append(item)
                }
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
