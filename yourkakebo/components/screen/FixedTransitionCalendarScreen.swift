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
            List {
                Section {
                    VStack(spacing: 6) {
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
                        .ListRowStyle()
                        // MARK: - Calendar
                        
                        
                        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                            ForEach(0..<((days.count + 6) / 7), id: \.self) { row in
                                Divider()
                                    .padding(.vertical, 0)
                                
                                GridRow{
                                    ForEach(0..<7, id: \.self) { column in
                                        let index = row * 7 + column
                                        
                                        if index < days.count, let date = days[index] {
                                            
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
                                        } else  {
                                            VStack{
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .ListRowStyle()
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: 16,
                    leading: 8,
                    bottom: 16,
                    trailing: 8
                ))
            }
            .ListStyle()
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
                
                VStack (spacing: 4) {
                    ForEach(calendarData.prefix(2)) { data in
                        Text("\(data.fixedTransition.fixedTransitionName)")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .lineLimit(1)
                            .background(Color(hex: data.fixedTransition.category?.colorHex ?? 0xFF888888), in: Capsule())
                    }
                }
                
                if calendarData.count > 2 {
                    Text("+\(calendarData.count - 2)")
                        .font(.system(size: 12))
                        .foregroundStyle(.blue)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 1)
            .frame(
                maxWidth: .infinity, minHeight: 98, alignment: .top
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                .background(Color(uiColor:.systemGroupedBackground))
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

