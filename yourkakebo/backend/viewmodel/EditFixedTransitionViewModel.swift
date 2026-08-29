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
    var category: CategoryModel? = nil
    var transitionType: TransitionType = .expense
    var amount: Int = 0
    var startDate: Date =  Date()
    var endDate: Date? = nil
    var cycleType: CycleType = .monthly
    var cycleInterval: Int? = nil
    var cycleValue: Int? = nil
    var cycleHolidayType: CycleHolidayType = .doNothing
    
    let fixedTransition: FixedTransitionModel?
    
    init(fixedTransition: FixedTransitionModel? , fixedTransitionService: FixedTransitionService, categoryService : CategoryService) {
        self.fixedTransition = fixedTransition
        self.fixedTransitionService = fixedTransitionService
        self.categoryService = categoryService
        
        if let fixedTransition {
            fixedTransitionName = fixedTransition.fixedTransitionName
            category = fixedTransition.category
            transitionType = fixedTransition.transitionType
            amount = fixedTransition.amount
            startDate = fixedTransition.startDate
            endDate = fixedTransition.endDate
            cycleType = fixedTransition.cycleType
            cycleInterval = fixedTransition.cycleInterval
            cycleValue = fixedTransition.cycleValue
            cycleHolidayType = fixedTransition.cycleHolidayType
        }
    }
    
    func load() throws {
        categories = try categoryService.getAllCategories()
    }
    
    var cycleOptionType: CycleOptionType {
        get {
            switch cycleType {
            case .daily:
                return .daily

            case .weekday:
                return .weekday

            case .weekly:
                return .weekly(cycleInterval ?? 1)

            case .monthly:
                return .monthly(cycleInterval ?? 1)

            case .yearly:
                return .yearly
            }
        }

        set {
            switch newValue {

            case .daily:
                cycleType = .daily
                cycleInterval = nil
                cycleValue = nil

            case .weekday:
                cycleType = .weekday
                cycleInterval = nil
                cycleValue = nil

            case .weekly(let interval):
                cycleType = .weekly
                cycleInterval = interval

                let swiftWeekday = Calendar.current.component(
                    .weekday,
                    from: startDate
                )

                cycleValue = swiftWeekday == 1
                    ? 7
                    : swiftWeekday - 1

            case .monthly(let interval):
                cycleType = .monthly
                cycleInterval = interval

                cycleValue = Calendar.current.component(
                    .day,
                    from: startDate
                )

            case .yearly:
                cycleType = .yearly
                cycleInterval = nil
                cycleValue = nil
            }
        }
    }
    
    func save() throws {
        if let fixedTransition {
            fixedTransitionName = fixedTransitionName
            category = category
            transitionType = transitionType
            amount = amount
            startDate = startDate
            endDate = endDate
            cycleType = cycleType
            cycleInterval = cycleInterval
            cycleValue = cycleValue
            cycleHolidayType = cycleHolidayType
            
            try fixedTransitionService.updateFixedTransition(fixedTransition)
        } else {
            try fixedTransitionService.addFixedTransition(
                FixedTransitionModel(
                    fixedTransitionName: fixedTransitionName,
                    category: category,
                    transitionType: transitionType,
                    amount: amount,
                    startDate: startDate,
                    endDate: endDate,
                    cycleType: cycleType,
                    cycleInterval: cycleInterval,
                    cycleValue: cycleValue,
                    cycleHolidayType: cycleHolidayType,
                    isActive: true
                    
                ))
        }
    }
    
    
}
