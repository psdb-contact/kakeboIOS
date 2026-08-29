//
//  HistoryCalendarViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/25.
//

import Foundation
import Observation

@Observable
final class HistoryViewModel {
    private let transitionService: TransitionService
    private let fixedTransitionService: FixedTransitionService
    
    var data: [HistoryCalendarData] = []
    
    
    var fixedTransitionPerDate: [Date: [FixedTransitionModel]] = [:]
    var transitionPerDate: [Date:[TransitionModel]] = [:]
    
    var selectedMonth: Date = Date()
    
    init(transitionService: TransitionService, fixedTransitionService: FixedTransitionService) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
    }
    
    func load() throws {
        
        data = []
        fixedTransitionPerDate = [:]
        transitionPerDate = [:]
        
        let calendar = Calendar.current
        
        let monthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: selectedMonth
            )
        )!
        
        let monthEnd = calendar.date(
            byAdding: .month,
            value: 1,
            to: monthStart
        )!
        
        let searchStart = calendar.date(
            byAdding: .day,
            value: -7,
            to: monthStart
        )!
        
        let searchEnd = calendar.date(
            byAdding: .day,
            value: 7,
            to: monthEnd
        )!
        
        
        let fixedTransitionList = try fixedTransitionService.getAllFixedTransitions()
        let transitionsList = try transitionService.getAllTransitions()
        
        
        for item in fixedTransitionList {
            guard item.isActive else {
                continue
            }
            
            let occurrenceDates = item.occurrenceDates(
                periodStart: searchStart,
                periodEnd: searchEnd,
                calendar: calendar
            )
            
            for date in occurrenceDates {
                guard date >= monthStart && date < monthEnd else {
                    continue
                }
                fixedTransitionPerDate[date, default: []].append(item)
            }
        }
        
        for item in transitionsList {
            let date = calendar.startOfDay(for: item.transitionDate)
            transitionPerDate[date, default: []].append(item)
        }
            
            let calcStart = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: selectedMonth
                )
            )!
            
            let calcEnd = calendar.date(
                byAdding: .month,
                value: 1,
                to: monthStart
            )!
            
            var calcDate = calcStart
            while calcDate < calcEnd {
                let fixedTransitions = fixedTransitionPerDate[calcDate] ?? []
                let transitions = transitionPerDate[calcDate] ?? []
                
                var totalIncome = 0
                var totalExpense = 0
                
                for item in fixedTransitions {
                    switch item.transitionType {
                    case .income:
                        totalIncome += item.amount
                    case .expense:
                        totalExpense += item.amount
                    }            }
                
                for item in transitions {
                    switch item.transitionType {
                    case .income:
                        totalIncome += item.amount
                    case .expense:
                        totalExpense += item.amount
                    }
                }
                
                data.append(
                    HistoryCalendarData(
                        totalIncome: totalIncome,
                        totalExpense: totalExpense,
                        date: calcDate
                    )
                )
                
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: calcDate) else {
                    break
                }
                
                calcDate = nextDate
            
            let today = calendar.startOfDay(for: Date())
            
            transitions = transitionPerDate[today] ?? []
            fixedTransitions = fixedTransitionPerDate[today] ?? []
        }
        
        func moveMonth(by value: Int) {
            
            let calendar = Calendar.current
            
            selectedMonth = calendar.date(
                byAdding: .month,
                value: value,
                to: selectedMonth
            ) ?? selectedMonth
        }
    }
    
    struct HistoryCalendarData: Identifiable {
        let id = UUID()
        
        let totalIncome: Int
        let totalExpense: Int
        
        let date: Date
    }
