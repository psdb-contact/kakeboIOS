//
//  ReportViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/27.
//

import Foundation
import Observation

@Observable
final class ReportViewModel {
    
    private let transitionService: TransitionService
    private let fixedTransitionService: FixedTransitionService
    
    var data: ReportDataModel?
    
    var reportPeriodType: ReportPeriodType = .monthly
    
    var selectedDate: Date
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService
    ) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
        
        let calendar = Calendar.current
        self.selectedDate = calendar.startOfDay(for: Date())
    }
    
    // MARK: - Load
    
    func load() throws {
        
        let calendar = Calendar.current
        
        // MARK: - 期間
        
        let periodStart: Date
        let periodEnd: Date
        
        switch reportPeriodType {
            
        case .yearly:
            periodStart = calendar.date(
                from: calendar.dateComponents(
                    [.year],
                    from: selectedDate
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
                    from: selectedDate
                )
            )!
            
            periodEnd = calendar.date(
                byAdding: .month,
                value: 1,
                to: periodStart
            )!
        }
        
        // MARK: - データ取得
        
        let transitions = try transitionService.getAllTransitions()
        
        let fixedTransitions =
        try fixedTransitionService.getAllFixedTransitions()
        
        // MARK: - 通常収支
        
        let periodTransitions = transitions.filter {
            
            let date = calendar.startOfDay(
                for: $0.transitionDate
            )
            
            return date >= periodStart &&
            date < periodEnd
        }
        
        let expenses = periodTransitions.filter {
            $0.transitionType == .expense
        }
        
        let incomes = periodTransitions.filter {
            $0.transitionType == .income
        }
        
        // MARK: - 固定収支
        
        let activeFixedTransitions = fixedTransitions.filter {
            $0.isActive
        }
        
        let fixedExpenses = activeFixedTransitions.filter {
            
            $0.transitionType == .expense &&
            !$0.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).isEmpty
        }
        
        let fixedIncomes = activeFixedTransitions.filter {
            
            $0.transitionType == .income &&
            !$0.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).isEmpty
        }
        
        // MARK: - 通常収支合計
        
        let totalDailyExpense = expenses.reduce(0) {
            $0 + $1.amount
        }
        
        let totalDailyIncome = incomes.reduce(0) {
            $0 + $1.amount
        }
        
        // MARK: - 固定収支合計
        
        let totalFixedExpense = fixedExpenses.reduce(0) {
            result,
            transition in
            
            let occurrenceCount =
            transition.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).count
            
            return result + transition.amount * occurrenceCount
        }
        
        let totalFixedIncome = fixedIncomes.reduce(0) {
            result,
            transition in
            
            let occurrenceCount =
            transition.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).count
            
            return result + transition.amount * occurrenceCount
        }
        
        // MARK: - 全体合計
        
        let totalExpense =
        totalDailyExpense +
        totalFixedExpense
        
        let totalIncome =
        totalDailyIncome +
        totalFixedIncome
        
        let totalBalance =
        totalIncome -
        totalExpense
        
        // MARK: - 通常支出カテゴリ集計
        
        var dailyExpenseAmounts: [CategoryModel?: Int] = [:]
        
        for transition in expenses {
            
            dailyExpenseAmounts[
                transition.category,
                default: 0
            ] += transition.amount
        }
        
        let aggregatedDailyExpenses =
        dailyExpenseAmounts.map {
            category,
            amount in
            
            CategoryReportDataModel(
                category: category,
                amount: amount
            )
        }
        
        // MARK: - 通常収入カテゴリ集計
        
        var dailyIncomeAmounts: [CategoryModel?: Int] = [:]
        
        for transition in incomes {
            
            dailyIncomeAmounts[
                transition.category,
                default: 0
            ] += transition.amount
        }
        
        let aggregatedDailyIncomes =
        dailyIncomeAmounts.map {
            category,
            amount in
            
            CategoryReportDataModel(
                category: category,
                amount: amount
            )
        }
        
        // MARK: - 固定支出カテゴリ集計
        
        var fixedExpenseAmounts: [CategoryModel?: Int] = [:]
        
        for transition in fixedExpenses {
            
            let occurrenceCount =
            transition.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).count
            
            let amount =
            transition.amount *
            occurrenceCount
            
            fixedExpenseAmounts[
                transition.category,
                default: 0
            ] += amount
        }
        
        let aggregatedFixedExpenses =
        fixedExpenseAmounts.map {
            category,
            amount in
            
            CategoryReportDataModel(
                category: category,
                amount: amount
            )
        }
        
        // MARK: - 固定収入カテゴリ集計
        
        var fixedIncomeAmounts: [CategoryModel?: Int] = [:]
        
        for transition in fixedIncomes {
            
            let occurrenceCount =
            transition.occurrenceDates(
                periodStart: periodStart,
                periodEnd: periodEnd,
                calendar: calendar
            ).count
            
            let amount =
            transition.amount *
            occurrenceCount
            
            fixedIncomeAmounts[
                transition.category,
                default: 0
            ] += amount
        }
        
        let aggregatedFixedIncomes =
        fixedIncomeAmounts.map {
            category,
            amount in
            
            CategoryReportDataModel(
                category: category,
                amount: amount
            )
        }
        
        // MARK: - Report Data
        
        data = ReportDataModel(
            totalBalance: totalBalance,
            totalExpense: totalExpense,
            totalIncome: totalIncome,
            totalDailyExpense: totalDailyExpense,
            totalDailyIncome: totalDailyIncome,
            totalFixedExpense: totalFixedExpense,
            totalFixedIncome: totalFixedIncome,
            aggregatedDailyExpenses: aggregatedDailyExpenses,
            aggregatedDailyIncomes: aggregatedDailyIncomes,
            aggregatedFixedExpenses: aggregatedFixedExpenses,
            aggregatedFixedIncomes: aggregatedFixedIncomes
        )
    }
    
    // MARK: - Date
    
    func setReportPeriodType(value: ReportPeriodType) {
        reportPeriodType = value
        
        try? load()
    }
    
    func moveMonth(by value: Int) {
        
        let calendar = Calendar.current
        
        selectedDate =
        calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) ?? selectedDate
        
        try? load()
        
    }
    
    func moveYear(by value: Int) {
        
        let calendar = Calendar.current
        
        selectedDate =
        calendar.date(
            byAdding: .year,
            value: value,
            to: selectedDate
        ) ?? selectedDate
        
        try? load()
        
    }
}


// MARK: - Category Report

struct CategoryReportDataModel: Identifiable {
    
    let id = UUID()
    
    let category: CategoryModel?
    
    let amount: Int
}


// MARK: - Report

struct ReportDataModel {
    
    let totalBalance: Int
    
    let totalExpense: Int
    
    let totalIncome: Int
    
    let totalDailyExpense: Int
    
    let totalDailyIncome: Int
    
    let totalFixedExpense: Int
    
    let totalFixedIncome: Int
    
    let aggregatedDailyExpenses: [CategoryReportDataModel]
    
    let aggregatedDailyIncomes: [CategoryReportDataModel]
    
    let aggregatedFixedExpenses: [CategoryReportDataModel]
    
    let aggregatedFixedIncomes: [CategoryReportDataModel]
}
