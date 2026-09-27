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
                targetDate: date,
                calendar: calendar
            ) {
                let resolvedDate = resolveHoliday(
                    targetDate: date,
                    calendar: calendar
                )
                
                dates.append(resolvedDate)
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
    
    // MARK: - Occurrence Check
    
    private func isOccurrence(
        targetDate: Date,
        calendar: Calendar
    ) -> Bool {
        
        guard targetDate >= startDate else {
            return false
        }
        
        if let endDate {
            guard targetDate <= endDate else {
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
                from: startDate,
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
                from: startDate
            )
            
            let startMonth = calendar.component(
                .month,
                from: startDate
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
                from: startDate
            )
            
            let startDay = calendar.component(
                .day,
                from: startDate
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
    
    var cycleDisplayString: String {
        let calendar = Calendar.current

        switch cycleType {
        case .daily:
            if let cycleInterval, cycleInterval > 1 {
                return "\(cycleInterval)日ごと"
            }
            return "毎日"

        case .weekday:
            return "平日"

        case .weekly:
            guard let cycleValue else {
                return cycleInterval == 1 ? "毎週" : "\(cycleInterval ?? 1)週間毎"
            }

            let weekdayNames = [
                1: "月曜",
                2: "火曜",
                3: "水曜",
                4: "木曜",
                5: "金曜",
                6: "土曜",
                7: "日曜"
            ]

            let weekday = weekdayNames[cycleValue] ?? ""

            if cycleInterval == 1 {
                return "毎週 \(weekday)"
            } else {
                return "\(cycleInterval ?? 1)週間毎 \(weekday)"
            }

        case .monthly:
            guard let cycleValue else {
                return cycleInterval == 1 ? "毎月" : "\(cycleInterval ?? 1)ヶ月ごと"
            }

            if cycleInterval == 1 {
                return "毎月 \(cycleValue)日"
            } else {
                return "\(cycleInterval ?? 1)ヶ月毎 \(cycleValue)日"
            }

        case .yearly:
            let month = calendar.component(.month, from: startDate)
            let day = calendar.component(.day, from: startDate)

            return "毎年 \(month)月\(day)日"
        }
    }
}
