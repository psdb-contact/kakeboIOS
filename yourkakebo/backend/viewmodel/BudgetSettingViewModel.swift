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
    var alertEditingBudgetData: BudgetSettingData?
    
    var alertDeleteBudgetData: BudgetSettingData?
    
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
    
    func save(isPeriod: Bool) throws {
        guard let alertEditingBudgetData else {
            return
        }

        do {
            if let index = budgetData.firstIndex(where: {
                $0.id == alertEditingBudgetData.id
            }) {
                let data = budgetData[index]

                if let amountInput, let amount = Int(amountInput) {
                    let budget: BudgetModel

                    if let existingBudget = data.budget {
                        existingBudget.amount = amount
                        existingBudget.endMonth = isPeriod
                            ? BudgetModel.noExpirationDate
                            : existingBudget.endMonth

                        try budgetService.updateBudget(existingBudget)
                        budget = existingBudget
                    } else {
                        let newBudget = BudgetModel(
                            category: data.category,
                            amount: amount,
                            startMonth: selectedMonth,
                            endMonth: isPeriod
                                ? BudgetModel.noExpirationDate
                                : selectedMonth
                        )

                        try budgetService.updateBudget(newBudget)
                        budget = newBudget
                    }

                    budgetData[index].budget = budget

                } else if let existingBudget = data.budget {
                    try budgetService.deleteBudget(
                        budget: existingBudget,
                        targetMonth: selectedMonth,
                        isPeriod: isPeriod
                    )

                    budgetData[index].budget = nil
                }

            } else if allBudgetData.id == alertEditingBudgetData.id {
                if let amountInput, let amount = Int(amountInput) {
                    let budget: BudgetModel

                    if let existingBudget = allBudgetData.budget {
                        existingBudget.amount = amount
                        existingBudget.endMonth = isPeriod
                            ? BudgetModel.noExpirationDate
                            : existingBudget.endMonth

                        try budgetService.updateBudget(existingBudget)
                        budget = existingBudget
                    } else {
                        let newBudget = BudgetModel(
                            category: nil,
                            amount: amount,
                            startMonth: selectedMonth,
                            endMonth: isPeriod
                                ? BudgetModel.noExpirationDate
                                : selectedMonth
                        )

                        try budgetService.updateBudget(newBudget)
                        budget = newBudget
                    }

                    allBudgetData.budget = budget

                } else if let existingBudget = allBudgetData.budget {
                    try budgetService.deleteBudget(
                        budget: existingBudget,
                        targetMonth: selectedMonth,
                        isPeriod: isPeriod
                    )

                    allBudgetData.budget = nil
                }
            }

            self.editingBudgetData = nil

        } catch {
            throw error
        }
    }
    
    func delete(_ isPeriod: Bool) throws {
        guard let alertDeleteBudgetData else {
            return
        }

        do {
            if let index = budgetData.firstIndex(where: {
                $0.id == alertDeleteBudgetData.id
            }) {
                if let existingBudget = budgetData[index].budget {
                    try budgetService.deleteBudget(
                        budget: existingBudget,
                        targetMonth: selectedMonth,
                        isPeriod: isPeriod
                    )
                }

                budgetData[index].budget = nil

            } else if allBudgetData.id == alertDeleteBudgetData.id {
                if let existingBudget = allBudgetData.budget {
                    try budgetService.deleteBudget(
                        budget: existingBudget,
                        targetMonth: selectedMonth,
                        isPeriod: isPeriod
                    )
                }

                allBudgetData.budget = nil
            }

            self.alertDeleteBudgetData = nil

        } catch {
            // エラー処理
        }
    }
    
    func cancel() {
        amountInput = nil
        alertEditingBudgetData = nil
        editingBudgetData = nil
    }
    
    func setTotal() {
        let total = budgetData
            .filter { $0.category != nil }
            .compactMap { $0.budget?.amount }
            .reduce(0, +)
        
        amountInput = String(total)
    }
    
    func setAlertBudgetData() {
        alertEditingBudgetData = editingBudgetData
        editingBudgetData = nil
    }
    
    func setEditingBudgetData(_ data: BudgetSettingData) {
        amountInput = data.budget.map { String($0.amount)}
        
        editingBudgetData = data
    }
    
    func moveMonth(by value: Int) {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        ) ?? selectedMonth
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
