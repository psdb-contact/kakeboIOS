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
    
    var selectedMonth: Date = Calendar.current.startOfDay(for: Date())
    var budgetData: [BudgetSettingData] = []
    
    var editingBudgetID: UUID?
    var isSaving = false
    
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
                budget: budget,
                category: category,
                amount: budget != nil ?  budget!.amount : 0,
                editingAmount: budget != nil ? budget!.amount : 0
            )
        }
    }
    
    func moveMonth(by value: Int) {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) ?? selectedMonth
    }
    
    func save(isPeriod: Bool) throws {
        guard let editingBudgetID else {
                 return
             }
        
        guard let index = budgetData.firstIndex(
            where: {$0.id == editingBudgetID }
        ) else {
                return
        }
        
        let data = budgetData[index]
        
        let amount = data.editingAmount ?? data.amount
        
        if let budget = data.budget {
            budget.amount = amount
            budget.endMonth =  isPeriod ? BudgetModel.noExpirationDate : budget.endMonth

            try? budgetService.updateBudget(budget)
        } else {
                let newBudget = BudgetModel(
                    category: data.category,
                    amount: amount,
                    startMonth: selectedMonth,
                    endMonth: isPeriod ? BudgetModel.noExpirationDate : selectedMonth,
                )
            
            try? budgetService.updateBudget(newBudget)
        }
        
        budgetData[index].editingAmount = amount
        self.editingBudgetID = nil
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
    
    var budget: BudgetModel?
    let category: CategoryModel
    let amount: Int
    var editingAmount: Int?
}
