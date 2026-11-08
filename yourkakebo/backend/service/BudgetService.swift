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
    
    func getAllBudgets() throws -> [BudgetModel] {
        try budgetRepository.getAllBudgets()
    }
    
    func getAllBudgetsByMonth(_ month: Date) throws -> [BudgetModel] {
        try budgetRepository.getAllBudgetsByMonth(month)
    }
    
    func getAllBudgetsByPeriod(start: Date, end: Date) throws -> [BudgetModel] {
        try budgetRepository.getAllBudgetsByPeriod(start: start, end: end)
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
    
    func deleteBudget(budget: BudgetModel, targetMonth: Date, isPeriod: Bool) throws {
        if isPeriod{
            try deletePeriod(budget: budget, targetMonth: targetMonth)
        } else {
            try deleteMonth(budget: budget, targetMonth: targetMonth)
        }
    }
    
    /*
    private func resolveBudgetForCategory(
        _ category: CategoryModel,
        budgets: [BudgetModel],
        month: Date
    ) -> BudgetModel? {
        let list = budgets.filter {
            $0.category?.categoryId == category.categoryId
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
     */
    
    // MARK: - Edit
    
    private func editMonth(_ budget: BudgetModel) throws {
        let existing = try budgetRepository.findMonthBudget(
            categoryId: budget.category?.categoryId,
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
            
            try budgetRepository.insertBudget(newBudget)
        }
        try modelContext.save()
    }
    
    private func editPeriod(_ budget: BudgetModel) throws {
        let month = budget.startMonth
        
        try modelContext.transaction {
            try budgetRepository.deleteBudgetsStartingFrom(
                categoryId: budget.category?.categoryId,
                month: month
            )
            
            let currentPeriod = try budgetRepository.findCoveringPeriodBudget(
                categoryId: budget.category?.categoryId,
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
            
            try budgetRepository.insertBudget(newBudget)
        }
    }
    
    // MARK: - Delete
    
    private func deleteMonth(budget: BudgetModel, targetMonth: Date) throws {
        
        let covering = try budgetRepository.findCoveringPeriodBudget(
            categoryId: budget.category?.categoryId,
            month: targetMonth
        )
        
        let single = try budgetRepository.findMonthBudget(
            categoryId: budget.category?.categoryId,
            month: targetMonth
        )
        
        try modelContext.transaction {
            if let single {
                try budgetRepository.deleteBudget(single)
            }
            
            guard let covering else {
                    return
            }
            
            let next = nextMonth(targetMonth)
            let previous = previousMonth(targetMonth)

            if covering.startMonth == targetMonth {
                covering.startMonth = next
                try budgetRepository.updateBudget(covering)
                return
            }
            
            if covering.endMonth == targetMonth {
                covering.endMonth = previous
                try budgetRepository.updateBudget(covering)
                return
            }
            
            let newBudget = BudgetModel(
                category: covering.category,
                amount: covering.amount,
                startMonth: next,
                endMonth: covering.endMonth
            )
            try budgetRepository.insertBudget(newBudget)
            
            covering.endMonth = previous
            try budgetRepository.updateBudget(covering)
        }
    }
    
    private func deletePeriod(budget: BudgetModel, targetMonth: Date) throws {
        try modelContext.transaction {
            try budgetRepository.deleteBudgetsStartingFrom(
                categoryId: budget.category?.categoryId,
                month: targetMonth
            )
            
            let current = try budgetRepository.findCoveringPeriodBudget(
                categoryId: budget.category?.categoryId,
                month: targetMonth
            )
            
            if let current {
                current.endMonth = previousMonth(targetMonth)
                
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
    
    private func nextMonth(_ date: Date) -> Date {
        Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: date
        )!
    }
}
