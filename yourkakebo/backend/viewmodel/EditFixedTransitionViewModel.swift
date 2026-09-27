//
//  EditFixedTransitionViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/18.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class EditFixedTransitionViewModel {
    private let fixedTransitionService: FixedTransitionService
    private let categoryService: CategoryService
    
    let fixedTransition: FixedTransitionModel?
    
    var toast: ToastData?
    var showCategorySheet = false
    var showCycleTypeSheet = false
    var showHolidayTypeSheet = false
    var showStartDateSheet = false
    var showEndDateSheet = false
    
    var editingCategory: CategoryModel? = nil
    var editingCycleOptionType: CycleOptionType? = nil
    var editingCycleHoliday: CycleHolidayType? = nil
    var editingStartDate: Date? = nil
    var editingEndDate: Date? = nil
    
    var categories: [CategoryModel] = []
    
    var fixedTransitionName: String = ""
    var amountInput: String  = "0"
    var category: CategoryModel? = nil
    var transitionType: TransitionType = .expense
    var startDate: Date =  Calendar.current.startOfDay(for: Date())
    var endDate: Date? = nil
    var cycleOptionType: CycleOptionType = .monthly(1)
    var cycleHolidayType: CycleHolidayType = .doNothing
    
    init(fixedTransition: FixedTransitionModel? , fixedTransitionService: FixedTransitionService, categoryService : CategoryService) {
        self.fixedTransition = fixedTransition
        self.fixedTransitionService = fixedTransitionService
        self.categoryService = categoryService
        
        if let fixedTransition {
            fixedTransitionName = fixedTransition.fixedTransitionName
            category = fixedTransition.category
            transitionType = fixedTransition.transitionType
            amountInput = String(fixedTransition.amount)
            startDate = fixedTransition.startDate
            endDate = fixedTransition.endDate
            cycleOptionType = Self.makeCycleOptionType(from: fixedTransition)
            cycleHolidayType = fixedTransition.cycleHolidayType
        }
    }
    
    func load() throws {
        categories = try categoryService.getAllCategories()
    }
    
    private static func makeCycleOptionType(
        from fixedTransition: FixedTransitionModel
    ) -> CycleOptionType {
        switch fixedTransition.cycleType {
            case .daily:
                return .daily
                
            case .weekday:
                return .weekday
                
            case .weekly:
                return .weekly(fixedTransition.cycleInterval ?? 1)
                
            case .monthly:
                return .monthly(fixedTransition.cycleInterval ?? 1)
                
            case .yearly:
                return .yearly
        }
    }
    
    private func makeCycleData() -> (
        type: CycleType,
        interval: Int?,
        value: Int?
    ) {
        switch cycleOptionType {
            case .daily:
                return (.daily, nil, nil)
                
            case .weekday:
                return (.weekday, nil, nil)
                
            case .weekly(let interval):
                let weekday = Calendar.current.component(
                    .weekday,
                    from: startDate
                )
                
                let cycleValue = weekday == 1
                ? 7
                : weekday - 1
                
                return (.weekly, interval, cycleValue)
                
            case .monthly(let interval):
                let cycleValue = Calendar.current.component(
                    .day,
                    from: startDate
                )
                
                return (.monthly, interval, cycleValue)
                
            case .yearly:
                return (.yearly, nil, nil)
            }
    }
    
    func save() throws {
        let name = fixedTransitionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw EditFixedTransitionError.emptyName
        }
        
        guard let amountValue = Int(amountInput),
              amountValue > 0 else {
            throw EditFixedTransitionError.invalidAmount
        }
        
        if let endDate, endDate < startDate {
            throw EditFixedTransitionError.invalidDateRange
        }
        
        let cycleData = makeCycleData()
        
        if let fixedTransition {
            fixedTransition.fixedTransitionName = fixedTransitionName
            fixedTransition.category = category
            fixedTransition.transitionType = transitionType
            fixedTransition.amount = amountValue
            fixedTransition.startDate = startDate
            fixedTransition.endDate = endDate
            fixedTransition.cycleType = cycleData.type
            fixedTransition.cycleInterval = cycleData.interval
            fixedTransition.cycleValue = cycleData.value
            fixedTransition.cycleHolidayType = cycleHolidayType
            
            try fixedTransitionService.updateFixedTransition(fixedTransition)
        } else {
            try fixedTransitionService.addFixedTransition(
                FixedTransitionModel(
                    fixedTransitionName: fixedTransitionName,
                    category: category,
                    transitionType: transitionType,
                    amount: amountValue,
                    startDate: startDate,
                    endDate: endDate,
                    cycleType: cycleData.type,
                    cycleInterval: cycleData.interval,
                    cycleValue: cycleData.value,
                    cycleHolidayType: cycleHolidayType,
                    isActive: true
                    
                ))
        }
    }
    
    
}
