//
//  FixedTransitionCalendarScreen.swift
//  yourkakebo
//

import SwiftUI

struct FixedTransitionCalendarScreen: View {
    
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        FixedTransitionCalendarContentScreen(
            fixedTransitionService: appContainer.fixedTransitionService
        )
    }
}

private struct FixedTransitionCalendarContentScreen: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    private let fixedTransitionService: FixedTransitionService
    
    @State private var viewModel: FixedTransitionCalendarViewModel
    
    init(
        fixedTransitionService: FixedTransitionService
    ) {
        self.fixedTransitionService = fixedTransitionService
        
        _viewModel = State(
            initialValue: FixedTransitionCalendarViewModel(
                fixedTransitionService: fixedTransitionService
            )
        )
    }
    
    var body: some View {
        
        @Bindable var viewModel = viewModel
        
        let calendar = Calendar.current
        
        let year = calendar.component(
            .year,
            from: viewModel.selectedDate
        )
        
        let month = calendar.component(
            .month,
            from: viewModel.selectedDate
        )
        
        VStack(spacing: 0) {
            
            // MARK: - Month Navigation
            
            HStack {
                
                Button {
                    viewModel.moveMonth(by: -1)
                } label: {
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            Color(.darkGray)
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )
                }
                
                Spacer()
                
                Text("\(year) / \(month)")
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color(
                            red: 0.133,
                            green: 0.133,
                            blue: 0.133
                        )
                    )
                
                Spacer()
                
                Button {
                    viewModel.moveMonth(by: 1)
                } label: {
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            Color(.darkGray)
                        )
                        .frame(
                            width: 44,
                            height: 44
                        )
                }
            }
            .padding(.horizontal, 16)
            
            // MARK: - Weekday
            
            HStack(spacing: 0) {
                
                ForEach(
                    ["日", "月", "火", "水", "木", "金", "土"],
                    id: \.self
                ) { weekday in
                    
                    Text(weekday)
                        .font(
                            .system(
                                size: 11,
                                weight: .medium
                            )
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
            
            // MARK: - Calendar
            
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: 1
                    ),
                    count: 7
                ),
                spacing: 1
            ) {
                
                ForEach(
                    Array(days.enumerated()),
                    id: \.offset
                ) { _, date in
                    
                    if let date {
                        
                        FixedTransitionCalendarDayCell(
                            date: date,
                            calendarData: viewModel.data.filter {
                                calendar.isDate(
                                    $0.date,
                                    inSameDayAs: date
                                )
                            }
                        )
                        
                    } else {
                        
                        Color.clear
                            .aspectRatio(
                                1,
                                contentMode: .fit
                            )
                    }
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .task(id: viewModel.selectedDate) {
            do {
                try viewModel.load()
            } catch {
                print("fixedTransitionの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    
    // MARK: - Days
    
    private var days: [Date?] {
        
        let calendar = Calendar.current
        
        guard let monthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: viewModel.selectedDate
            )
        ) else {
            return []
        }
        
        let weekday = calendar.component(
            .weekday,
            from: monthStart
        )
        
        let leadingEmptyDays = weekday - 1
        
        guard let range = calendar.range(
            of: .day,
            in: .month,
            for: monthStart
        ) else {
            return []
        }
        
        var result: [Date?] = []
        
        // 月初までの空セル
        for _ in 0..<leadingEmptyDays {
            result.append(nil)
        }
        
        // その月の日付
        for day in range {
            
            guard let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthStart
            ) else {
                continue
            }
            
            result.append(date)
        }
        
        return result
    }
}

// MARK: - Day Cell

private struct FixedTransitionCalendarDayCell: View {
    
    let date: Date
    
    let calendarData: [
        FixedTransitionCalendarData
    ]
    
    var body: some View {
        
        VStack(spacing: 2) {
            
            Text("\(Calendar.current.component(.day, from: date))")
            
            ForEach(calendarData) { data in
                Text(
                    "\(data.fixedTransition.amount)"
                )
                .font(
                    .system(size: 11)
                )
            }
            
            Spacer(minLength: 0)
        }
        .frame(
            maxWidth: .infinity
        )
        .aspectRatio(
            1,
            contentMode: .fit
        )
    }
}
