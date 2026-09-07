//
//  PreviewFixedTransitionData.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import Foundation

@MainActor
enum PreviewFixedTransitionData {

    static func make() -> [FixedTransitionModel] {

        let categories = PreviewCategoryData.make()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let currentMonthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: today
            )
        )!

        let previousMonthStart = calendar.date(
            byAdding: .month,
            value: -1,
            to: currentMonthStart
        )!

        let twoMonthsAgo = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentMonthStart
        )!

        let nextMonthStart = calendar.date(
            byAdding: .month,
            value: 1,
            to: currentMonthStart
        )!

        let endOfCurrentMonth = calendar.date(
            byAdding: .day,
            value: -1,
            to: nextMonthStart
        )!

        return [

            // MARK: - Monthly

            FixedTransitionModel(
                fixedTransitionName: "家賃",
                category: categories[6],
                transitionType: .expense,
                amount: 80000,
                startDate: previousMonthStart,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 25,
                cycleHolidayType: .before,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "サブスク",
                category: categories[3],
                transitionType: .expense,
                amount: 1480,
                startDate: twoMonthsAgo,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 10,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "電気代",
                category: categories[4],
                transitionType: .expense,
                amount: 8500,
                startDate: currentMonthStart,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 27,
                cycleHolidayType: .after,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "給与",
                category: categories[9],
                transitionType: .income,
                amount: 300000,
                startDate: previousMonthStart,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 25,
                cycleHolidayType: .before,
                isActive: true
            ),

            // 2ヶ月ごと

            FixedTransitionModel(
                fixedTransitionName: "保険",
                category: categories[8],
                transitionType: .expense,
                amount: 12000,
                startDate: twoMonthsAgo,
                cycleType: .monthly,
                cycleInterval: 2,
                cycleValue: 5,
                cycleHolidayType: .after,
                isActive: true
            ),

            // 3ヶ月ごと

            FixedTransitionModel(
                fixedTransitionName: "美容院",
                category: categories[3],
                transitionType: .expense,
                amount: 7000,
                startDate: twoMonthsAgo,
                cycleType: .monthly,
                cycleInterval: 3,
                cycleValue: 15,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - Weekly

            FixedTransitionModel(
                fixedTransitionName: "毎週の交通費",
                category: categories[2],
                transitionType: .expense,
                amount: 3000,
                startDate: previousMonthStart,
                cycleType: .weekly,
                cycleInterval: 1,
                cycleValue: 1,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // 2週間ごと

            FixedTransitionModel(
                fixedTransitionName: "隔週の買い物",
                category: categories[1],
                transitionType: .expense,
                amount: 5000,
                startDate: previousMonthStart,
                cycleType: .weekly,
                cycleInterval: 2,
                cycleValue: 6,
                cycleHolidayType: .after,
                isActive: true
            ),

            // MARK: - Weekday

            FixedTransitionModel(
                fixedTransitionName: "平日の昼食",
                category: categories[0],
                transitionType: .expense,
                amount: 800,
                startDate: currentMonthStart,
                cycleType: .weekday,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - Daily

            FixedTransitionModel(
                fixedTransitionName: "毎日の支出",
                category: categories[0],
                transitionType: .expense,
                amount: 500,
                startDate: today,
                cycleType: .daily,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "毎日の食費",
                category: categories[0],
                transitionType: .expense,
                amount: 1200,
                startDate: today,
                cycleType: .daily,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "毎日の収入",
                category: categories[9],
                transitionType: .income,
                amount: 3000,
                startDate: today,
                cycleType: .daily,
                cycleHolidayType: .doNothing,
                isActive: true
            ),
            
            FixedTransitionModel(
                fixedTransitionName: "毎日の収入2",
                category: categories[2],
                transitionType: .income,
                amount: 1200,
                startDate: today,
                cycleType: .daily,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - Yearly

            FixedTransitionModel(
                fixedTransitionName: "年払い保険",
                category: categories[8],
                transitionType: .expense,
                amount: 60000,
                startDate: calendar.date(
                    byAdding: .year,
                    value: -1,
                    to: currentMonthStart
                )!,
                cycleType: .yearly,
                cycleHolidayType: .before,
                isActive: true
            ),

            FixedTransitionModel(
                fixedTransitionName: "年末ボーナス",
                category: categories[9],
                transitionType: .income,
                amount: 500000,
                startDate: calendar.date(
                    from: DateComponents(
                        year: calendar.component(.year, from: currentMonthStart) - 1,
                        month: 12,
                        day: 20
                    )
                )!,
                cycleType: .yearly,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - End Date

            FixedTransitionModel(
                fixedTransitionName: "期間限定サブスク",
                category: categories[3],
                transitionType: .expense,
                amount: 980,
                startDate: previousMonthStart,
                endDate: endOfCurrentMonth,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 1,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - Future

            FixedTransitionModel(
                fixedTransitionName: "来月からの固定収入",
                category: categories[10],
                transitionType: .income,
                amount: 50000,
                startDate: nextMonthStart,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 15,
                cycleHolidayType: .doNothing,
                isActive: true
            ),

            // MARK: - Inactive

            FixedTransitionModel(
                fixedTransitionName: "停止中の固定収支",
                category: categories[1],
                transitionType: .expense,
                amount: 5000,
                startDate: twoMonthsAgo,
                cycleType: .monthly,
                cycleInterval: 1,
                cycleValue: 20,
                cycleHolidayType: .doNothing,
                isActive: false
            )
        ]
    }
}

