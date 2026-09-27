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
    var showSetEndDate: Bool = false
    
    var budgetData: [BudgetSettingData] = []
    
    var focusedDataId: UUID?
    var editingDataId: UUID?
    var isSaving = false
    
    init (budgetService: BudgetService, categoryService: CategoryService)  {
        self.budgetService = budgetService
        self.categoryService = categoryService
    }
    
    func load(_ selectedMonth: Date) throws {
        let budgets = try budgetService.getAllBudgetsByMonth(selectedMonth)
        let categories = try categoryService.getAllCategoriesByTransitionType(.expense)
        let baseCategories: [CategoryModel?] = [nil] + categories
                
        budgetData = baseCategories.map { category in
            let budget = resolveBudget(
                for: category,
                budgets: budgets,
                month: selectedMonth
            )
            
            return BudgetSettingData(
                budget: budget,
                category: category,
                amountInput: budget != nil ? String(budget!.amount) : nil
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
    
    func setTotal() throws {
        guard let editingDataId else {
                 return
             }
        
        guard let index = budgetData.firstIndex(
            where: {$0.id == editingDataId }
        ) else {
                return
        }
        
        let data = budgetData[index]
        
        let total = budgetData
            .filter { $0.category != nil }
            .compactMap { $0.budget?.amount }
            .reduce(0, +)
        
        let budget: BudgetModel
        
        if let existingBudget = data.budget {
            existingBudget.amount = total
            existingBudget.endMonth = selectedMonth

            try? budgetService.updateBudget(existingBudget)
            budget = existingBudget
        } else {
                let newBudget = BudgetModel(
                    category: data.category,
                    amount: total,
                    startMonth: selectedMonth,
                    endMonth: selectedMonth,
                )
            
            try? budgetService.updateBudget(newBudget)
            budget = newBudget
        }
        
        budgetData[index].amountInput = String(total)
        budgetData[index].budget = budget
        
        self.editingDataId = nil
        
    }
    
    func save(isPeriod: Bool) throws {
        guard let editingDataId else {
            return
        }
        
        guard let index = budgetData.firstIndex(where: {$0.id == editingDataId }) else {
            return
        }
        
        let data = budgetData[index]
        
        if let amountInput = data.amountInput, let amount = Int(amountInput) {
            let budget: BudgetModel
            
            if let exisitingBudget = data.budget {
                exisitingBudget.amount = amount
                exisitingBudget.endMonth =  isPeriod ? BudgetModel.noExpirationDate : exisitingBudget.endMonth

                try? budgetService.updateBudget(exisitingBudget)
                budget = exisitingBudget
                
            } else {
                let newBudget = BudgetModel(
                    category: data.category,
                    amount: amount,
                    startMonth: selectedMonth,
                    endMonth: isPeriod ? BudgetModel.noExpirationDate : selectedMonth,
                )
                
                try? budgetService.updateBudget(newBudget)
                budget = newBudget
            }
            
            budgetData[index].amountInput = String(amount)
            budgetData[index].budget = budget
            
            
        } else {
            if let exisitingBudget = data.budget {
                try? budgetService.deleteBudget(exisitingBudget)
                budgetData[index].amountInput = nil
                budgetData[index].budget = nil
            }
        }
    
        self.focusedDataId = nil
        self.editingDataId = nil
    }
    
    private func resolveBudget(
        for category: CategoryModel?,
        budgets: [BudgetModel],
        month: Date
    ) -> BudgetModel? {
        
        let list = budgets.filter {
            $0.category?.categoryId == category?.categoryId
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
    let category: CategoryModel?
    var amountInput: String?
}
