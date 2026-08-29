//
//  BudgetSettingViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class BudgetSettingViewModel {
    private let budgetService: BudgetService
    private let categoryService: CategoryService
    
    var budgetToEdit: BudgetModel? = nil
    var selectedDate: Date = Date()
    var budgetData: Array<BudgetSettingData> = []
    var showEditBudget = false
    
    init (budgetService: BudgetService, categoryService: CategoryService) {
        self.budgetService = budgetService
        self.categoryService = categoryService
    }
    
    func load(_ selectedMonth: Date) throws {
        
        let categories = try categoryService.getAllCategories()
        let budgets = try budgetService.getAllBudgetsByMonth(selectedMonth)
        
        budgetData = categories.map { category in
            let budget = resolveBudget(
                for: category,
                budgets: budgets,
                month: selectedMonth
            )
            
            return BudgetSettingData(
                category: category,
                budget: budget
            )
        }
    }
    
    func moveDate(by value: Int) {
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: selectedDate
        ) ?? selectedDate
    }
    
    func selectBudgetToEdit(_ budget: BudgetModel) {
        budgetToEdit = budget
    }
    
    private func resolveBudget(
        for category: CategoryModel,
        budgets: [BudgetModel],
        month: Date
    ) -> BudgetModel? {
        
        let list = budgets.filter {
            $0.category.categoryId == category.categoryId
        }
        
        var selected: BudgetModel?
        
        for budget in list {
            guard inRange(budget, month) else {
                continue
            }
            
            let isSingle = budget.startMonth == budget.endMonth
            
            if isSingle && budget.startMonth == month {
                return budget
            }
            
            selected = budget
        }
        
        return selected
    }
    
    private func inRange(
        _ budget: BudgetModel,
        _ month: Date
    ) -> Bool {
        let start = monthValue(budget.startMonth)
        let end = monthValue(budget.endMonth)
        let target = monthValue(month)
        
        return start <= target && target <= end
    }
    
    private func monthValue(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: date
        )
        
        return (components.year! * 12) + components.month!
    }
}

struct BudgetSettingData: Identifiable {
    let id = UUID()
    
    let category: CategoryModel
    let budget: BudgetModel?
}
