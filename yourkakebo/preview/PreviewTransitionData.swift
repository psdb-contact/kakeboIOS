//
//  PreviewTransitionData.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import Foundation

@MainActor
enum PreviewTransitionData {

    static func make() -> [TransitionModel] {

        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        func date(
            year: Int,
            month: Int,
            day: Int
        ) -> Date {
            calendar.date(
                from: DateComponents(
                    year: year,
                    month: month,
                    day: day
                )
            )!
        }

        let categories = PreviewCategoryData.make()

        return [

            // **MARK: - 今月**

            TransitionModel(
                amount: 1200,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 1
                ),
                createdAt: now,
                category: categories[0],
                memo: "昼食"
            ),

            TransitionModel(
                amount: 3500,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 3
                ),
                createdAt: now,
                category: categories[1],
                memo: "電車・バス"
            ),

            TransitionModel(
                amount: 5800,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 5
                ),
                createdAt: now,
                category: categories[2],
                memo: "日用品"
            ),

            TransitionModel(
                amount: 9800,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 8
                ),
                createdAt: now,
                category: categories[0],
                memo: "外食"
            ),

            // **MARK: - 今日**

            TransitionModel(
                amount: 980,
                transitionType: .expense,
                transitionDate: today,
                createdAt: now,
                category: categories[0],
                memo: "朝食"
            ),

            TransitionModel(
                amount: 2480,
                transitionType: .expense,
                transitionDate: today,
                createdAt: now,
                category: categories[2],
                memo: "日用品"
            ),

            TransitionModel(
                amount: 12000,
                transitionType: .income,
                transitionDate: today,
                createdAt: now,
                category: categories[4],
                memo: "副業収入"
            ),


            // **MARK: - 未来**

            TransitionModel(
                amount: 15000,
                transitionType: .income,
                transitionDate: date(
                    year: 2026,
                    month: 10,
                    day: 10
                ),
                createdAt: now,
                category: categories[2],
                memo: "臨時収入"
            ),

            // **MARK: - 過去**

            TransitionModel(
                amount: 4200,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 7,
                    day: 15
                ),
                createdAt: now,
                category: categories[3],
                memo: "映画"
            ),

            TransitionModel(
                amount: 250000,
                transitionType: .income,
                transitionDate: date(
                    year: 2026,
                    month: 7,
                    day: 25
                ),
                createdAt: now,
                category: categories[4],
                memo: "給与"
            ),

            // **MARK: - 未分類**

            TransitionModel(
                amount: 780,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 12
                ),
                createdAt: now,
                category: nil,
                memo: "未分類の支出"
            ),

            // **MARK: - 高額**

            TransitionModel(
                amount: 85000,
                transitionType: .expense,
                transitionDate: date(
                    year: 2026,
                    month: 8,
                    day: 20
                ),
                createdAt: now,
                category: categories[5],
                memo: "家電購入"
            )
        ]
    }
}
