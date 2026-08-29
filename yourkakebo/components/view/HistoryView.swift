//
//  HistoryView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/16.
//

import SwiftUI

struct HistoryView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        HistoryContentView(
            transitionService: appContainer.transitionService,
            fixedTransitionService: appContainer.fixedTransitionService
        )
    }
}

private struct HistoryContentView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    private let transitionService: TransitionService
    private let fixedTransitionService: FixedTransitionService
    
    @State private var viewModel: HistoryViewModel
    
    init(transitionService: TransitionService, fixedTransitionService: FixedTransitionService) {
        self.transitionService = transitionService
        self.fixedTransitionService = fixedTransitionService
        
        _viewModel = State(
            initialValue:
                HistoryViewModel(
                    transitionService: transitionService, fixedTransitionService: fixedTransitionService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        let calendar = Calendar.current
        
        VStack(spacing: 8) {
            
            
            ZStack {
                
                MonthNavigationBar(
                    formattedDate: formattedDate,
                    onPrevious: {
                        viewModel.moveMonth(by: -1)
                    },
                    onNext:  {
                        viewModel.moveMonth(by: 1)
                    }
                )
                
            }
            
            
            HStack(spacing: 0) {
                
                ForEach(
                    ["日", "月", "火", "水", "木", "金", "土"],
                    id: \.self
                ) { weekday in
                    
                    Text(weekday)
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                }
            }
            .padding(.bottom, 4)
            
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
                    Array(
                        days.enumerated()),
                    id: \.offset) {
                        _, date in
                        
                        if let date {
                            let data = viewModel.data.first {
                                calendar.isDate(
                                    $0.date,
                                    inSameDayAs: date
                                )
                            }
                            
                            HistoryCalendarDayCell(
                                date: date,
                                income: data?.totalIncome ?? 0,
                                expense: data?.totalExpense ?? 0,
                                onDateSelected: {date in viewModel.setSelectedDate(date: date)
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
            ScrollView{
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.transitions) {
                        item in
                        HistoryTransitionCard(transition: item)
                    }
                    ForEach(viewModel.fixedTransitions) { item in
                        HistoryFixedTransitionCard(fixedTransition: item)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task() {
            do {
                try viewModel.load()
            } catch {
                print("データの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M"
        
        return formatter.string(
            from: viewModel.selectedDate
        )
    }
    
    private var days: [Date?] {
        
        let calendar = Calendar.current
        
        guard let monthStart = calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: viewModel.selectedMonth
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
    
    private struct HistoryCalendarDayCell: View {
        let date: Date
        
        let income: Int
        let expense: Int
        
        let onDateSelected: (Date) -> Void
        
        var body: some View {
            Button {
                onDateSelected(date)
            } label: {
                VStack(spacing: 6) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                    
                    if(income > 0) {
                        Text("\(income)")
                            .font(.system(size: 11))
                            .foregroundStyle(.blue)
                    }
                    if(expense > 0) {
                        Text("\(expense)")
                            .font(.system(size: 11))
                            .foregroundStyle(.red)
                    }
                }
                .frame(
                    maxWidth: .infinity, minHeight: 80, alignment: .top
                )
            }
            
        }
    }
    
    private struct HistoryTransitionCard: View {
        let transition: TransitionModel
        
        var body: some View {
            HStack(spacing: 0) {
                Text(transition.category?.categoryName ?? "")
                    .font(.system(size: 16))
                    .frame(
                        width: 92,
                        alignment: .leading
                    )
                Text("\(transition.amount)")
            }
        }
    }
    
    private struct HistoryFixedTransitionCard: View {
        let fixedTransition: FixedTransitionModel
        
        var body: some View {
            HStack(spacing: 0) {
                Text(fixedTransition.category?.categoryName ?? "")
                    .font(.system(size: 16))
                    .frame(
                        width: 92,
                        alignment: .leading
                    )
                
                Text("\(fixedTransition.amount)")
            }
        }
    }
}
