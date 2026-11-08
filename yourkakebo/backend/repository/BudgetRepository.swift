//
//  BudgetRepository.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@MainActor
final class BudgetRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllBudgets() throws -> [BudgetModel] {
        let descriptor = FetchDescriptor<BudgetModel> ()
        
        return try modelContext.fetch(descriptor)
    }
    
    func getAllBudgetsByMonth(_ month: Date) throws -> [BudgetModel] {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate {
                $0.startMonth <= month && $0.endMonth >= month
            },
            sortBy: [
                SortDescriptor(\.startMonth),
                SortDescriptor(\.endMonth)
            ]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func getAllBudgetsByPeriod(start: Date, end: Date) throws -> [BudgetModel] {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate {
                $0.startMonth < end && $0.endMonth >= start
            }
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func insertBudget(_ budget: BudgetModel) throws {
        modelContext.insert(budget)
    }
    
    func updateBudget(_ budget: BudgetModel) throws {
        // SwiftDataの変更追跡に任せる
    }
    
    func findMonthBudget(
        categoryId: UUID?,
        month: Date
    ) throws -> BudgetModel? {

        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.startMonth == month &&
                budget.endMonth == month
            }
        )

        let budgets = try modelContext.fetch(descriptor)

        return budgets.first {
            $0.category?.categoryId == categoryId
        }
    }
    
    func findCoveringPeriodBudget(
        categoryId: UUID?,
        month: Date
    ) throws -> BudgetModel? {
        let descriptor = FetchDescriptor<BudgetModel>(
             predicate: #Predicate { budget in
                 budget.startMonth <= month &&
                 budget.endMonth >= month
             }
         )

        let budgets = try modelContext.fetch(descriptor)

        return budgets.first {
            $0.category?.categoryId == categoryId &&
            $0.startMonth < $0.endMonth
        }
    }
    
    func deleteBudgetsStartingFrom(
        categoryId: UUID?,
        month: Date
    ) throws  {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.startMonth >= month
            }
        )
        
        let budgets = try modelContext.fetch(descriptor)
        
        for budget in budgets {
            if budget.category?.categoryId == categoryId {
                modelContext.delete(budget)
            }
        }
    }
    
    func deleteBudget(_ budget: BudgetModel) throws {
        modelContext.delete(budget)
    }
    
    func deleteAllBudgets() throws {
        let budgets = try modelContext.fetch(
               FetchDescriptor<BudgetModel>()
           )

       for budget in budgets {
           modelContext.delete(budget)
       }
    }
}
