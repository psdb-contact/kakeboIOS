//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditTransitionViewModel {
    
    let transitionService: TransitionService
    private let templateService: TemplateService
    
    
    // MARK: - State
    var expenses: [TransitionInputData] = []
    var incomes: [TransitionInputData] = []
    
    var uncategorizedExpenses: [UncategoriezedTransitionInputData] = []
    var uncategorizedIncomes: [UncategoriezedTransitionInputData] = []
    
    var expenseIds: [UUID] = []
    var incomeIds: [UUID] = []
    
    var showSelectCategory = false
    var showEditTransition = false
    var editingDataId: UUID? = nil
    var editingTransition: TransitionModel? = nil
    var editingCategory: CategoryModel? = nil
    
    var showAssignTransition = false
    var assigningTransitionData: UncategoriezedTransitionInputData? = nil
    
    var transitionDataToDelete: TransitionInputData? = nil
    var uncategorizedTransitionDataToDelete: UncategoriezedTransitionInputData? = nil
    
    var transitionPeriod: TransitionPeriod
    
    // MARK: - Init
    
    init(
        transitionService: TransitionService,
        templateService: TemplateService
    ) {
        self.transitionService = transitionService
        self.templateService = templateService
        
        let calendar = Calendar.current
        self.transitionPeriod = TransitionPeriod(type: .expense, date: calendar.startOfDay(for: Date()))
    }
    
    // MARK: - Action
    
    func moveDate(by value: Int) {
        
        let date = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: transitionPeriod.date
        ) ?? transitionPeriod.date
        
        transitionPeriod = TransitionPeriod(type: transitionPeriod.type, date: date)
    }
    
    func cancelDelete() {
        transitionDataToDelete = nil
    }
    
    func cancelUncategorizedDelete() {
        uncategorizedTransitionDataToDelete = nil
    }
    
    func load(transitionPeriod: TransitionPeriod) throws {
        
        var expenseResults:[TransitionInputData] = []
        var incomeResults: [TransitionInputData] = []
        
        let templates = try templateService.getAllTemplates()
        
        let expenseTeplates = templates.filter {
            $0.category.transitionType == .expense
        }
        
        let incomeTemplates = templates.filter {
            $0.category.transitionType == .income
        }
        
        let dateTransitions = try transitionService.getAllTransitionsByDate(transitionPeriod.date)
        
        let expenseTransitions = dateTransitions.filter {
            $0.transitionType == .expense
        }
        
        let incomeTransitions = dateTransitions.filter {
            $0.transitionType == .income
        }
        
        let expenseTemplateMap: [UUID: TemplateModel] = Dictionary(
            uniqueKeysWithValues: expenseTeplates.map {
                (
                    $0.category.categoryId,
                    $0
                )
            }
        )
        
        let incomeTemplateMap: [UUID: TemplateModel] = Dictionary(
            uniqueKeysWithValues: incomeTemplates.map {
                (
                    $0.category.categoryId,
                    $0
                )
            }
        )
        
        let expenseTransitionMap: [UUID: TransitionModel] = Dictionary(
            uniqueKeysWithValues: expenseTransitions.compactMap {
                transition -> (UUID, TransitionModel)? in
                
                guard let category = transition.category else {
                    return nil
                }
                
                return (
                    category.categoryId,
                    transition
                )
            }
        )
        
        let incomeTransitionMap: [UUID: TransitionModel] = Dictionary(
            uniqueKeysWithValues: incomeTransitions.compactMap {
                transition -> (UUID, TransitionModel)? in
                
                guard let category = transition.category else {
                    return nil
                }
                
                return (
                    category.categoryId,
                    transition
                )
            }
        )
        
        // MARK: Category IDs
        
        let allExpenseCategoryIds = Set(
            expenseTransitionMap.keys
        ).union(
            expenseTemplateMap.keys
        )
        
        let allIncomeCategoryIds = Set(
            incomeTransitionMap.keys
        ).union(
            incomeTemplateMap.keys
        )
        
        expenseIds = Array(allExpenseCategoryIds)
        incomeIds = Array(allIncomeCategoryIds)
        
        // MARK: Create View Data
        
        for categoryId in allExpenseCategoryIds {
            
            let transition = expenseTransitionMap[categoryId]
            let template = expenseTemplateMap[categoryId]
            
            // TransitionがあればTransition側のCategory、
            // なければTemplate側のCategoryを使用する。
            guard let category = (
                transition?.category
                ?? template?.category
            ) else {
                continue
            }
            
            
            expenseResults.append(
                TransitionInputData(
                    category: category,
                    transition: transition,
                    isTemplate: template != nil,
                )
            )
        }
        
        for categoryId in allIncomeCategoryIds {
            
            let transition = incomeTransitionMap[categoryId]
            let template = incomeTemplateMap[categoryId]
            
            // TransitionがあればTransition側のCategory、
            // なければTemplate側のCategoryを使用する。
            guard let category = (
                transition?.category
                ?? template?.category
            ) else {
                continue
            }
            
            
            incomeResults.append(
                TransitionInputData(
                    category: category,
                    transition: transition,
                    isTemplate: template != nil,
                )
            )
        }
        
        // MARK: Sort
        //
        // TemplateのsortOrder順。
        // Templateに存在しないCategoryは最後。
        
        expenseResults.sort { lhs, rhs in
            let lhsSortOrder = expenseTemplateMap[
                lhs.category.categoryId
            ]?.sortOrder ?? 9999
            
            let rhsSortOrder = expenseTemplateMap[
                rhs.category.categoryId
            ]?.sortOrder ?? 9999
            
            return lhsSortOrder < rhsSortOrder
        }
        expenses = expenseResults
        
        incomeResults.sort { lhs, rhs in
            let lhsSortOrder = incomeTemplateMap[
                lhs.category.categoryId
            ]?.sortOrder ?? 9999
            
            let rhsSortOrder = incomeTemplateMap[
                rhs.category.categoryId
            ]?.sortOrder ?? 9999
            
            return lhsSortOrder < rhsSortOrder
        }
        incomes = incomeResults
        
        let uncategorizedExpenseTransitions = expenseTransitions.filter {
            $0.category == nil
        }
        
        let uncategorizedIncomeTransitions = incomeTransitions.filter {
            $0.category == nil
        }
        
        var uncategorizedExpenseResults: [UncategoriezedTransitionInputData] = []
        for transition in uncategorizedExpenseTransitions {
            uncategorizedExpenseResults.append(
                UncategoriezedTransitionInputData(
                    transition: transition,
                )
            )
        }
        
        var uncategorizedIncomeResults: [UncategoriezedTransitionInputData] = []
        for transition in uncategorizedIncomeTransitions {
            uncategorizedIncomeResults.append(
                UncategoriezedTransitionInputData(
                    transition: transition,
                )
            )
        }
        
        uncategorizedExpenses = uncategorizedExpenseResults
        uncategorizedIncomes = uncategorizedIncomeResults
    }
    
    func assignCategory(_ category: CategoryModel) throws {
        let matchIndex = switch category.transitionType {
        case .expense:
            expenses.firstIndex(
                where: { $0.category.categoryId == category.categoryId }
            )
        case .income:
            incomes.firstIndex(
                where: { $0.category.categoryId == category.categoryId }
            )
        }

        let matchTransition: TransitionModel? = switch category.transitionType {
        case .expense:
            matchIndex.flatMap { expenses[$0].transition }

        case .income:
            matchIndex.flatMap { incomes[$0].transition }
        }
        
        if (matchTransition != nil) {
            let newAmount = matchTransition!.amount + assigningTransitionData!.transition.amount
            
            let newTransition = TransitionModel(
                transitionId: matchTransition!.transitionId,
                category: matchTransition!.category,
                amount: newAmount,
                transitionType: matchTransition!.transitionType,
                transitionDate: matchTransition!.transitionDate,
                createdAt: Date()
            )
            
            try transitionService.editAndDeleteTransition(edit: newTransition, delete: assigningTransitionData!.transition)
            
            if(category.transitionType == .expense) {
                uncategorizedExpenses.removeAll { $0.id == assigningTransitionData!.id }
                if let matchIndex {
                    expenses[matchIndex].transition = newTransition
                }
            } else {
                uncategorizedIncomes.removeAll { $0.id == assigningTransitionData!.id}
                if let matchIndex {
                    incomes[matchIndex].transition = newTransition
                }
            }
            
            
        } else {
            let newTransition = TransitionModel(
                category: category,
                amount: assigningTransitionData!.transition.amount,
                transitionType: assigningTransitionData!.transition.transitionType,
                transitionDate: assigningTransitionData!.transition.transitionDate,
                createdAt: Date()
            )
            
            try transitionService.addAndDeleteTransition(add: newTransition, delete: assigningTransitionData!.transition)
            
            if(category.transitionType == .expense) {
                uncategorizedExpenses.removeAll { $0.id == assigningTransitionData!.id }
                if let matchIndex {
                    expenses[matchIndex].transition = newTransition
                }
            } else {
                uncategorizedIncomes.removeAll { $0.id == assigningTransitionData!.id}
                if let matchIndex {
                    incomes[matchIndex].transition = newTransition
                }
            }
        }
        
        assigningTransitionData = nil
    }
    
    func deleteTransition() throws {
        guard let data = transitionDataToDelete else {
            return
        }
        
        guard let transition = data.transition else {
            return
        }
        
        let transitionType = transition.transitionType
        let dataId = data.id
        
        try transitionService.deleteTransition(transition)
        
        if transitionType == .expense {
             if let index = expenses.firstIndex(where: { $0.id == dataId }) {
                 expenses[index].transition = nil
             }
         } else {
             if let index = incomes.firstIndex(where: { $0.id == dataId }) {
                 incomes[index].transition = nil
             }
         }
    }
    
    func deleteUncategorizedTransition() throws {
        guard let data = uncategorizedTransitionDataToDelete else {
            return
        }
        
        let transition = data.transition
        
        let transitionType = transition.transitionType
        let dataId = data.id
        
        try transitionService.deleteTransition(transition)
        
        if transitionType == .expense {
            uncategorizedExpenses.removeAll { $0.id == dataId }
         } else {
             uncategorizedIncomes.removeAll { $0.id == dataId }
         }
    }
    
    func refreash(_ transition: TransitionModel) {
        if(transition.transitionType == .expense) {
            if let index = expenses.firstIndex(
                where: { $0.id == editingDataId }
            ){
                expenses[index].transition = transition
            } else {
                expenses.append(
                    TransitionInputData(
                        category: transition.category!,
                        transition: transition,
                        isTemplate: false,
                    )
                )
            }
            
        } else {
            if let index = incomes.firstIndex(
                where: { $0.id == editingDataId }
            ) {
                incomes[index].transition = transition
                
            } else {
                incomes.append(
                    TransitionInputData(
                        category: transition.category!,
                        transition: transition,
                        isTemplate: false
                    )
                )
            }
            
        }
    }
    
    func setTransitionPeriodType(_ transitionType: TransitionType) {
        transitionPeriod = TransitionPeriod(type: transitionType, date: transitionPeriod.date)
    }
    
    func setShowSelectedCategory() {
        showSelectCategory = true
    }
}

// MARK: - View Data

struct TransitionInputData: Identifiable {
    
    let id = UUID()
    
    let category: CategoryModel
    var transition: TransitionModel?
    let isTemplate: Bool
}

struct UncategoriezedTransitionInputData: Identifiable {
    let id = UUID()
    var transition: TransitionModel
}
