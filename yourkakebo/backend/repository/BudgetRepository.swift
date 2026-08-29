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

    func getAllBudgetsByMonth(_ month: Date) throws -> [BudgetModel] {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.startMonth <= month && budget.endMonth >= month
            },
            sortBy: [
                SortDescriptor(\.startMonth),
                SortDescriptor(\.endMonth)
            ]
        )

        return try modelContext.fetch(descriptor)
    }

    func addBudget(_ budget: BudgetModel) throws {
        modelContext.insert(budget)
        try modelContext.save()
    }

    func updateBudget(_ budget: BudgetModel) throws {
        try modelContext.save()
    }

    func findMonthBudget(
        categoryId: String,
        month: Date
    ) throws -> BudgetModel? {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.category.categoryId == categoryId &&
                budget.startMonth == month &&
                budget.endMonth == month
            }
        )

        return try modelContext.fetch(descriptor).first
    }

    func findCoveringPeriodBudget(
        categoryId: String,
        month: Date
    ) throws -> BudgetModel? {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.category.categoryId == categoryId &&
                budget.startMonth <= month &&
                budget.endMonth >= month
            }
        )

        return try modelContext.fetch(descriptor).first
    }

    func deleteBudgetsStartingFrom(
        categoryId: String,
        month: Date
    ) throws  {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.category.categoryId == categoryId &&
                budget.startMonth >= month
            }
        )

        let budgets = try modelContext.fetch(descriptor)

        for budget in budgets {
            modelContext.delete(budget)
        }

        try modelContext.save()
    }

    func deleteBudget(_ budget: BudgetModel) throws {
        modelContext.delete(budget)
        try modelContext.save()
    }

    func deleteBudget(_ id: UUID) throws {
        let descriptor = FetchDescriptor<BudgetModel>(
            predicate: #Predicate { budget in
                budget.budgetId == id
            }
        )

        guard let budget = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(budget)
        try modelContext.save()
    }
}
