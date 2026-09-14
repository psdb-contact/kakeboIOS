//
//  BudgetReportViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/11.
//

import Foundation
import Observation

@Observable
final class BudgetReportViewModel {
    private let transitionService: TransitionService
    private let fixedTransitionService: FixedTransitionService
    private let budgetService: BudgetService
    
    var data: [BudgetReportDataModel] = []
    var period: ReportPeriod
    
    init(transitionService:  TransitionService, fixedTransitionService: FixedTransitionService, budgetService: BudgetService) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
        self.budgetService = budgetService
        
        let calendar = Calendar.current
       self.period = ReportPeriod(
           type: .monthly,
           date: calendar.startOfDay(for: Date())
       )
    }
    
    func load(period: ReportPeriod) throws {
        let calendar = Calendar.current
        
        let periodStart: Date
        let periodEnd: Date
        
        switch period.type {
        case .yearly:
            periodStart = calendar.date(
                from: calendar.dateComponents(
                    [.year],
                    from: period.date
                )
            )!
            
            periodEnd = calendar.date(
                byAdding: .year,
                value: 1,
                to: periodStart
            )!
        case .monthly:
            periodStart = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: period.date
                )
            )!
            
            periodEnd = calendar.date(
                byAdding: .month,
                value: 1,
                to: periodStart
            )!
        }
        
        let searchStart = calendar.date(
            byAdding: .day,
            value: -7,
            to: periodStart
        )!
        
        let searchEnd = calendar.date(
            byAdding: .day,
            value: 7,
            to: periodEnd
        )!
        
        let transitions = try transitionService.getAllExpenses()
        let periodTransitions = transitions.filter {
            let date = calendar.startOfDay(
                for: $0.transitionDate
            )
            return date >= periodStart && date < periodEnd
        }
        
        var balancePerCategory: [CategoryModel?: Int] = [:]
        
        for transition in periodTransitions {
            
            balancePerCategory[nil, default: 0] += transition.amount
            if let category = transition.category {
                balancePerCategory[category, default: 0] += transition.amount
            }
        }
        
        let fixedTransitions = try fixedTransitionService.getAllFixedExpenses()
        
        let activeFixedTransitions = fixedTransitions.filter {
            $0.isActive
        }
        
        let fixedTransitionOccurrences: [FixedTransitionModel: [Date]] = Dictionary(
            uniqueKeysWithValues: activeFixedTransitions.map { transition in
                let dates = transition
                    .occurrenceDates(
                        searchStart: searchStart,
                        searchEnd: searchEnd,
                        calendar: calendar
                    )
                    .filter {
                        $0 >= periodStart &&
                        $0 < periodEnd
                    }
                
                return (transition, dates)
            }
        )
        
        for (fixedTransition, occurrence) in fixedTransitionOccurrences {
            let totalAmount = fixedTransition.amount * occurrence.count
            
            balancePerCategory[nil, default: 0] += totalAmount
            
            if let category = fixedTransition.category {
                balancePerCategory[category, default: 0] += totalAmount
            }
        }
        
        var result: [BudgetReportDataModel] = []
        
        switch period.type {
            case .yearly:
                let budgets = try budgetService.getAllBudgetsByPeriod(start: periodStart, end: periodEnd)
                var budgetPerCategory: [CategoryModel?: Int] = [:]
                
                for monthOffset in 0..<12 {
                    guard let month = calendar.date(
                        byAdding: .month,
                        value: monthOffset,
                        to: periodStart
                    ) else {
                        continue
                    }
                    
                    for budget in budgets where budget.startMonth <= month && budget.endMonth >= month {
                        budgetPerCategory[budget.category, default: 0] += budget.amount
                    }
                }
                
                for (category, budgetAmount) in budgetPerCategory {
                    result.append(BudgetReportDataModel(
                        category: category,
                        budgetAmount: budgetAmount,
                        balanceAmount: balancePerCategory[category, default: 0]
                    ))
                }
                
            case .monthly:
            let budgets = try budgetService.getAllBudgetsByPeriod(start: periodStart, end: periodEnd)

                for budget in budgets {
                    result.append(
                        BudgetReportDataModel(
                            category: budget.category,
                            budgetAmount: budget.amount,
                            balanceAmount: balancePerCategory[budget.category, default: 0]
                        )
                    )
                }
            }
        
        data = result
    }
    
    func setReportPeriodType(value: ReportPeriodType) {
            period = ReportPeriod(
                    type: value,
                    date: period.date
                )
        }
        
        func moveMonth(by value: Int) {
            let calendar = Calendar.current
            
            let date = calendar.date(
                          byAdding: .month,
                          value: value,
                          to: period.date
                      ) ?? period.date

            period = ReportPeriod(type: period.type,date: date)
        }

        func moveYear(by value: Int) {
            let calendar = Calendar.current
            
            let date = calendar.date(
                     byAdding: .year,
                     value: value,
                     to: period.date
                 ) ?? period.date

            period = ReportPeriod(type: period.type,date: date)
        }
}


struct BudgetReportDataModel: Identifiable {
    let id = UUID()
    let category: CategoryModel?
    
    let budgetAmount: Int
    let balanceAmount: Int
}
