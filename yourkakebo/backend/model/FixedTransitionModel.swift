//
//  FixedTransition.swift
//  yourkakebo
//

import SwiftData
import Foundation

@Model
final class FixedTransitionModel {

    @Attribute(.unique) var fixedTransitionId: UUID
    var fixedTransitionName: String
    var category: CategoryModel?
    var transitionType: TransitionType
    var amount: Int
    var startDate: Date
    var endDate: Date?
    var cycleType: CycleType
    var cycleInterval: Int?
    var cycleValue: Int?
    var cycleHolidayType: CycleHolidayType
    var isActive: Bool

    init(
        fixedTransitionId: UUID = UUID(),
        fixedTransitionName: String,
        category: CategoryModel?,
        transitionType: TransitionType,
        amount: Int,
        startDate: Date,
        endDate: Date? = nil,
        cycleType: CycleType,
        cycleInterval: Int? = nil,
        cycleValue: Int? = nil,
        cycleHolidayType: CycleHolidayType,
        isActive: Bool
    ) {
        self.fixedTransitionId = fixedTransitionId
        self.fixedTransitionName = fixedTransitionName
        self.category = category
        self.transitionType = transitionType
        self.amount = amount
        self.startDate = startDate
        self.endDate = endDate
        self.cycleType = cycleType
        self.cycleInterval = cycleInterval
        self.cycleValue = cycleValue
        self.cycleHolidayType = cycleHolidayType
        self.isActive = isActive
    }

    // MARK: - Occurrence
    func occurrenceDates(
        searchStart: Date,
        searchEnd: Date,
        calendar: Calendar = .current
    ) -> [Date] {

        var dates: [Date] = []

        var date = searchStart

        while date < searchEnd {

               if isOccurrence(
                    date: date,
                    calendar: calendar
               ) {
                   let resolvedDate = resolveHoliday(
                    targetDate: date,
                    calendar: calendar
                   )
                   
                   if resolvedDate >= searchStart,
                      resolvedDate < searchEnd {
                       
                       dates.append(resolvedDate)
                   }
               }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: date
            ) else {
                break
            }

            date = nextDate
        }

        return dates
    }

    /// 指定した期間内の発生回数を返す。
    func occurrenceCount(
        periodStart: Date,
        periodEnd: Date,
        calendar: Calendar = .current
    ) -> Int {

        occurrenceDates(
            periodStart: periodStart,
            periodEnd: periodEnd,
            calendar: calendar
        ).count
    }

    /// 指定した日に実際に発生するかを返す。
    func isOccurrence(
        on date: Date,
        calendar: Calendar = .current
    ) -> Bool {

        let targetDate = calendar.startOfDay(
            for: date
        )

        let nextDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: targetDate
        )!

        return !occurrenceDates(
            periodStart: targetDate,
            periodEnd: nextDate,
            calendar: calendar
        ).isEmpty
    }

    // MARK: - Occurrence Check

    private func isOccurrence(
        date: Date,
        calendar: Calendar
    ) -> Bool {

        let targetDate = calendar.startOfDay(
            for: date
        )

        let normalizedStartDate = calendar.startOfDay(
            for: startDate
        )

        guard targetDate >= normalizedStartDate else {
            return false
        }

        if let endDate {
            let normalizedEndDate = calendar.startOfDay(
                for: endDate
            )

            guard targetDate <= normalizedEndDate else {
                return false
            }
        }

        switch cycleType {

        case .daily:
            return true

        case .weekday:
            return !calendar.isDateInWeekend(
                targetDate
            )

        case .weekly:

            guard
                let cycleValue,
                let cycleInterval,
                cycleInterval > 0
            else {
                return false
            }

            let swiftWeekday = calendar.component(
                .weekday,
                from: targetDate
            )

            // Swift:
            // Sunday = 1
            // Monday = 2
            // ...
            // Saturday = 7
            //
            // アプリ:
            // Monday = 1
            // ...
            // Sunday = 7

            let weekday =
                swiftWeekday == 1
                ? 7
                : swiftWeekday - 1

            guard weekday == cycleValue else {
                return false
            }

            guard let dayDifference = calendar.dateComponents(
                [.day],
                from: normalizedStartDate,
                to: targetDate
            ).day else {
                return false
            }

            let weekDifference = dayDifference / 7

            return weekDifference % cycleInterval == 0

        case .monthly:

            guard
                let cycleValue,
                let cycleInterval,
                cycleInterval > 0
            else {
                return false
            }

            let targetDay = calendar.component(
                .day,
                from: targetDate
            )

            guard targetDay == cycleValue else {
                return false
            }

            let startYear = calendar.component(
                .year,
                from: normalizedStartDate
            )

            let startMonth = calendar.component(
                .month,
                from: normalizedStartDate
            )

            let targetYear = calendar.component(
                .year,
                from: targetDate
            )

            let targetMonth = calendar.component(
                .month,
                from: targetDate
            )

            let startMonthIndex =
                startYear * 12 + startMonth

            let targetMonthIndex =
                targetYear * 12 + targetMonth

            let monthDifference =
                targetMonthIndex - startMonthIndex

            guard monthDifference >= 0 else {
                return false
            }

            return monthDifference % cycleInterval == 0

        case .yearly:

            let startMonth = calendar.component(
                .month,
                from: normalizedStartDate
            )

            let startDay = calendar.component(
                .day,
                from: normalizedStartDate
            )

            let targetMonth = calendar.component(
                .month,
                from: targetDate
            )

            let targetDay = calendar.component(
                .day,
                from: targetDate
            )

            return startMonth == targetMonth &&
                   startDay == targetDay
        }
    }

    // MARK: - Holiday

    private func resolveHoliday(
        targetDate: Date,
        calendar: Calendar
    ) -> Date {

        guard calendar.isDateInWeekend(
            targetDate
        ) else {
            return targetDate
        }

        switch cycleHolidayType {

        case .doNothing:
            return targetDate

        case .before:

            var result = targetDate

            while calendar.isDateInWeekend(result) {

                guard let previous = calendar.date(
                    byAdding: .day,
                    value: -1,
                    to: result
                ) else {
                    break
                }

                result = previous
            }

            return result

        case .after:

            var result = targetDate

            while calendar.isDateInWeekend(result) {

                guard let next = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: result
                ) else {
                    break
                }

                result = next
            }

            return result
        }
    }
}
