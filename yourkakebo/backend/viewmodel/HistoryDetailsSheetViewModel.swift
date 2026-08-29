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
    
    let transitions: [TransitionModel] = []
    let fixedTransitions :[FixedTransitionModel] = []
 

    init(transitionService: TransitionService, fixedTransitionService: FixedTransitionService, selectedDate: Date) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
        self.selectedDate = selectedDate
    }
    
    func load() throws {
        let fixedTransitionList = try fixedTransitionService.getAllFixedTransitions()
        let transitionsList = try transitionService.getAllTransitions()
 
        let date = Calendar.current.startOfDay(for: selectedDate)

        for item in fixedTransitionList {
            guard item.isActive else {
                continue
            }
            
        }
    }
}
