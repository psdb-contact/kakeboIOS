//
//  FixedTransitionCalendarViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/23.
//

import Foundation
import Observation

@Observable
final class FixedTransitionCalendarViewModel {
    private let fixedTransitionService: FixedTransitionService
    
    var data: [FixedTransitionCalendarData] = []
    
    var selectedDate: Date = Date()
    
    init (fixedTransitionService: FixedTransitionService) {
        self.fixedTransitionService = fixedTransitionService
    }
    
    func load() throws {
        let calendar = Calendar.current
        
        let monthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: selectedDate
            )
        )!
        
        let monthEnd = calendar.date(
            byAdding: .month,
            value: 1,
            to: monthStart
        )!
        
        var result: [FixedTransitionCalendarData] = []
        
        let fixedTransitions = try fixedTransitionService.getAllFixedTransitions()
        
        var date = monthStart
        while date < monthEnd {
            for item in fixedTransitions {
                guard item.isActive else {
                    continue
                }

                let occurrenceDates = item.occurrenceDates(
                    periodStart: monthStart,
                    periodEnd: monthEnd,
                    calendar: calendar
                )

                for date in occurrenceDates {
                    result.append(
                        FixedTransitionCalendarData(
                            fixedTransition: item,
                            date: date
                        )
                    )
                }
            }
            guard let nextDate = calendar.date(byAdding: .day, value:1, to: date) else {
                break
            }
            date = nextDate
        }
        data = result.sorted {
            $0.date < $1.date
        }
    }
    
    func moveMonth(by value: Int) {

        let calendar = Calendar.current

        selectedDate = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) ?? selectedDate
    }
    
    func dailyData(targetDate: Date) -> [FixedTransitionCalendarData] {
        let calendar = Calendar.current
        
        return data.filter{
            calendar.isDate(
                $0.date,
                inSameDayAs: targetDate
            )
        }
    }
}

struct FixedTransitionCalendarData: Identifiable {
    let id = UUID()
    let fixedTransition: FixedTransitionModel
    let date: Date
}

