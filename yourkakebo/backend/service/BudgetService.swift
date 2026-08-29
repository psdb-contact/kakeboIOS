import Foundation
import SwiftData

final class BudgetService {
    private let modelContext: ModelContext
    private let budgetRepository: BudgetRepository

    init(
        modelContext: ModelContext,
        budgetRepository: BudgetRepository
    ) {
        self.modelContext = modelContext
        self.budgetRepository = budgetRepository
    }

    func getAllBudgetsByMonth(_ month: Date) throws -> [BudgetModel] {
        try budgetRepository.getAllBudgetsByMonth(month)
    }
    
    func addBudget(_ budget: BudgetModel) throws {
        
    }
 
    func updateBudget(_ budget: BudgetModel) throws {
        if budget.startMonth == budget.endMonth {
            try editMonth(budget)
        } else {
            try editPeriod(budget)
        }
    }

    func deleteBudget(_ budget: BudgetModel) throws {
        if budget.startMonth == budget.endMonth {
            try deleteMonth(budget)
        } else {
            try deletePeriod(budget)
        }
    }

    private func resolveBudgetForCategory(
        _ category: CategoryModel,
        budgets: [BudgetModel],
        month: Date
    ) -> BudgetModel? {
        let list = budgets.filter {
            $0.category.categoryId == category.categoryId
        }

        var selected: BudgetModel?

        for budget in list {
            guard inRange(budget, month: month) else {
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

    // MARK: - Edit

    private func editMonth(_ budget: BudgetModel) throws {
        let existing = try budgetRepository.findMonthBudget(
            categoryId: budget.category.categoryId,
            month: budget.startMonth
        )

        if let existing {
            existing.amount = budget.amount

            try budgetRepository.updateBudget(existing)
        } else {
            let newBudget = BudgetModel(
                category: budget.category,
                amount: budget.amount,
                startMonth: budget.startMonth,
                endMonth: budget.startMonth
            )

            try budgetRepository.addBudget(newBudget)
        }
    }

    private func editPeriod(_ budget: BudgetModel) throws {
        let month = budget.startMonth
        let categoryId = budget.category.categoryId

        try modelContext.transaction {
            try budgetRepository.deleteBudgetsStartingFrom(
                categoryId: categoryId,
                month: month
            )

            let currentPeriod = try budgetRepository.findCoveringPeriodBudget(
                categoryId: categoryId,
                month: month
            )

            if let currentPeriod {
                currentPeriod.endMonth = previousMonth(month)

                try budgetRepository.updateBudget(currentPeriod)
            }

            let newBudget = BudgetModel(
                category: budget.category,
                amount: budget.amount,
                startMonth: month,
                endMonth: BudgetModel.noExpirationDate
            )

            try budgetRepository.addBudget(newBudget)
        }
    }

    // MARK: - Delete

    private func deleteMonth(_ budget: BudgetModel) throws {
        let month = budget.startMonth
        let categoryId = budget.category.categoryId

        let covering = try budgetRepository.findCoveringPeriodBudget(
            categoryId: categoryId,
            month: month
        )

        let single = try budgetRepository.findMonthBudget(
            categoryId: categoryId,
            month: month
        )

        // 期間予算が存在する場合、
        // この月だけ0円という予算を作る
        if covering != nil {
            if let single {
                single.amount = 0

                try budgetRepository.updateBudget(single)
            } else {
                let newBudget = BudgetModel(
                    category: budget.category,
                    amount: 0,
                    startMonth: month,
                    endMonth: month
                )

                try budgetRepository.addBudget(newBudget)
            }

            return
        }

        // 月単位の予算しか存在しない場合は削除
        if let single {
            try budgetRepository.deleteBudget(single.budgetId)
        }
    }

    private func deletePeriod(_ budget: BudgetModel) throws {
        let month = budget.startMonth
        let categoryId = budget.category.categoryId

        try modelContext.transaction {
            try budgetRepository.deleteBudgetsStartingFrom(
                categoryId: categoryId,
                month: month
            )

            let current = try budgetRepository.findCoveringPeriodBudget(
                categoryId: categoryId,
                month: month
            )

            if let current {
                current.endMonth = previousMonth(month)

                try budgetRepository.updateBudget(current)
            }
        }
    }

    // MARK: - Helper

    private func inRange(
        _ budget: BudgetModel,
        month: Date
    ) -> Bool {
        budget.startMonth <= month &&
        month <= budget.endMonth
    }

    private func previousMonth(_ date: Date) -> Date {
        Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: date
        )!
    }
}
