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
            appSettings: appContainer.appSettings,
            fixedTransitionService: appContainer.fixedTransitionService
        )
    }
}

private struct FixedTransitionCalendarContentScreen: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    private let appSettings: AppSettings
    private let fixedTransitionService: FixedTransitionService
    
    @State private var viewModel: FixedTransitionCalendarViewModel
    
    init(
        appSettings: AppSettings,
        fixedTransitionService: FixedTransitionService
    ) {
        self.appSettings = appSettings
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
        
        
        VStack(spacing: 0) {
            
            // MARK: - Month Navigation
            
            
            PeriodNavigationBar(
                formattedDate: formattedMonth(viewModel.selectedMonth), onPrevious:  {viewModel.moveMonth(by: -1)}, onNext: {viewModel.moveMonth(by: 1)}
            )
            
            // MARK: - Weekday
            
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday.displayShortName)
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 16)
            
            Divider()
                .padding(.top, 4)
            
            // MARK: - Calendar
            
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: 0
                    ),
                    count: 7
                ),
                spacing: 0
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
                            },
                            onDateSelected: {date in
                                viewModel.selectedDate = date
                                viewModel.showDetailsSheet = true
                            }
                        )
                        
                    } else {
                        VStack{
                            Spacer()
                            Divider()
                        }
                    }
                }
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showDetailsSheet) {
            if(viewModel.selectedDate != nil) {
                NavigationStack {
                    FixedTransitionDetailsSheet(
                        fixedTransitionService: fixedTransitionService,
                        selectedDate: viewModel.selectedDate!
                    )
                    .presentationDragIndicator(.hidden)
                }
            }
        }
        .task(id: viewModel.selectedMonth) {
            do {
                try viewModel.load()
            } catch {
                print("fixedTransitionの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private var weekdays: [Weekday] {
        let all = Weekday.allCases
        let startIndex = all.firstIndex(of: appSettings.weeklyStartDay) ?? 0
        
        return Array(all[startIndex...]) + Array(all[..<startIndex])
    }
    
    // MARK: - Days
    
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
        
        let calendarWeekday = calendar.component(
            .weekday,
            from: monthStart
        )
        
        let leadingEmptyDays = (calendarWeekday - appSettings.weeklyStartDay.rawValue + 7) % 7
        
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
    
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        
        Button {
            onDateSelected(date)
        }label: {
            VStack(spacing: 8) {
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                
                ForEach(calendarData.prefix(2)) { data in
                    Text("\(data.fixedTransition.amount)")
                        .font(.system(size: 11))
                        .foregroundStyle(data.fixedTransition.transitionType == .expense ? Color.red : Color.blue)
                }
                
                if calendarData.count > 2 {
                    Text("+\(calendarData.count - 2)")
                        .font(.system(size: 11))
                }
                
                Spacer()
                Divider()
            }
            .padding(.top, 6)
            .frame(
                maxWidth: .infinity, minHeight: 80, alignment: .top
            )
        }
    }
    
}


import SwiftData

#Preview {
    PreviewContent()
}

@MainActor
private struct PreviewContent: View {
    
    private let container: ModelContainer
    private let appContainer: AppContainer
    
    init() {
        let container = try! ModelContainer(
            for:
                CategoryModel.self,
            TransitionModel.self,
            BudgetModel.self,
            TemplateModel.self,
            FixedTransitionModel.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )
        
        let context = container.mainContext
        
        PreviewSeeder.seed(
            context: context
        )
        
        self.container = container
        self.appContainer = AppContainer(
            modelContext: context
        )
    }
    
    var body: some View {
        NavigationStack{
            FixedTransitionCalendarScreen()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

