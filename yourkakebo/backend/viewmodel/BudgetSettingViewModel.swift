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
    
    var allBudgetData: BudgetSettingData = BudgetSettingData(budget: nil, category: nil)
    var budgetData: [BudgetSettingData] = []
    
    var editingBudgetData: BudgetSettingData?
    var amountInput: String?
    
    var alertBudgetData: BudgetSettingData?
    
    init (budgetService: BudgetService, categoryService: CategoryService)  {
        self.budgetService = budgetService
        self.categoryService = categoryService
    }
    
    func load(_ selectedMonth: Date) throws {
        let budgets = try budgetService.getAllBudgetsByMonth(selectedMonth)
        let categories = try categoryService.getAllCategoriesByTransitionType(.expense)
        
        let budgetForAll = resolveBudget(for: nil, budgets: budgets, month: selectedMonth )
        allBudgetData.budget = budgetForAll
        
        budgetData = categories.map { category in
            let budget = resolveBudget(
                for: category,
                budgets: budgets,
                month: selectedMonth
            )
            
            return BudgetSettingData(
                budget: budget,
                category: category,
            )
        }
    }
    
    func setAlertBudgetData() {
        alertBudgetData = editingBudgetData
        editingBudgetData = nil
    }
    
    func moveMonth(by value: Int) {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) ?? selectedMonth
    }
    
    func cancel() {
        guard let editingBudgetData else {
            return
        }
        
        guard let index = budgetData.firstIndex(where: {$0.id == editingBudgetData.id }) else {
            return
        }
        
   
        self.editingBudgetData = nil
    }
    
    func cancelAll() {
            
    }
    
    func setTotal() throws {
        let total = budgetData
            .filter { $0.category != nil }
            .compactMap { $0.budget?.amount }
            .reduce(0, +)
        
        let budget: BudgetModel
        
        if let existingBudget = allBudgetData.budget {
            existingBudget.amount = total
            existingBudget.endMonth = selectedMonth
            
            try? budgetService.updateBudget(existingBudget)
            budget = existingBudget
        } else {
            let newBudget = BudgetModel(
                category: nil,
                amount: total,
                startMonth: selectedMonth,
                endMonth: selectedMonth,
            )
            
            try? budgetService.updateBudget(newBudget)
            budget = newBudget
        }
        
        allBudgetData.budget = budget
        
        self.editingBudgetData = nil
        
    }
    
    func save(isPeriod: Bool) throws {
        guard let editingBudgetData else {
            return
        }
        
        guard let index = budgetData.firstIndex(where: {$0.id == editingBudgetData.id }) else {
            return
        }
        
        let data = budgetData[index]
        
        if let amountInput = amountInput, let amount = Int(amountInput) {
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
            
            
            
        } else {
            if let exisitingBudget = data.budget {
                try? budgetService.deleteBudget(exisitingBudget)
                budgetData[index].budget = nil
            }
        }
        
        self.editingBudgetData = nil
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

struct BudgetSettingData: Identifiable, Hashable {
    let id = UUID()
    
    var budget: BudgetModel?
    let category: CategoryModel?
}
