//
//  PreviewBudgetData.swift
//  yourkakebo
//

import Foundation

@MainActor
enum PreviewBudgetData {

    static func make() ->  [BudgetModel] {

        let categories = PreviewCategoryData.make()
        let calendar = Calendar.current

        let today = calendar.startOfDay(for: Date())

        let currentMonth = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: today
            )
        )!

        let previousMonth = calendar.date(
            byAdding: .month,
            value: -1,
            to: currentMonth
        )!

        let twoMonthsAgo = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentMonth
        )!

        let nextMonth = calendar.date(
            byAdding: .month,
            value: 1,
            to: currentMonth
        )!

        let threeMonthsLater = calendar.date(
            byAdding: .month,
            value: 3,
            to: currentMonth
        )!

        return [

            // MARK: - 今月のみ

            BudgetModel(
                category: categories[0],
                amount: 30000,
                startMonth: currentMonth,
                endMonth: currentMonth
            ),

            BudgetModel(
                category: categories[1],
                amount: 15000,
                startMonth: currentMonth,
                endMonth: currentMonth
            ),

            BudgetModel(
                category: categories[2],
                amount: 10000,
                startMonth: currentMonth,
                endMonth: currentMonth
            ),

            BudgetModel(
                category: categories[3],
                amount: 5000,
                startMonth: currentMonth,
                endMonth: currentMonth
            ),

            // MARK: - 過去から継続中

            BudgetModel(
                category: categories[4],
                amount: 12000,
                startMonth: twoMonthsAgo,
                endMonth: BudgetModel.noExpirationDate
            ),

            BudgetModel(
                category: categories[5],
                amount: 8000,
                startMonth: previousMonth,
                endMonth: BudgetModel.noExpirationDate
            ),

            // MARK: - 複数ヶ月の期間

            BudgetModel(
                category: categories[6],
                amount: 80000,
                startMonth: currentMonth,
                endMonth: threeMonthsLater
            ),

            BudgetModel(
                category: categories[7],
                amount: 20000,
                startMonth: previousMonth,
                endMonth: nextMonth
            ),

            // MARK: - 来月から

            BudgetModel(
                category: categories[8],
                amount: 10000,
                startMonth: nextMonth,
                endMonth: BudgetModel.noExpirationDate
            ),

            // MARK: - 大きめの予算

            BudgetModel(
                category: categories[9],
                amount: 100000,
                startMonth: currentMonth,
                endMonth: BudgetModel.noExpirationDate
            ),

            // MARK: - 小さめの予算

            BudgetModel(
                category: categories[10],
                amount: 1000,
                startMonth: currentMonth,
                endMonth: currentMonth
            )
        ]
    }
}
