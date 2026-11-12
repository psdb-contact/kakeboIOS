//
//  ReportView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/16.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            SettingContentView(appSettings: appContainer.appSettings)
        }
    }
}

private struct SettingContentView: View {
    //let appSettings: AppSettings
    
    @State private var viewModel: SettingViewModel
    
    init(appSettings: AppSettings
    ) {
        //self.appSettings = appSettings
        
        _viewModel = State(initialValue: SettingViewModel(appSettings: appSettings))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        List {
            Section {
                NavigationLink {
                    TemplateSettingView()
                } label: {
                    HStack {
                        Text("テンプレート設定").font(.system(size: 16)).foregroundStyle(.black)
                        Spacer()
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
                
                NavigationLink {
                    CategorySettingView()
                } label: {
                    HStack {
                        Text("カテゴリ設定").font(.system(size: 16)).foregroundStyle(.black)
                        Spacer()
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
                
                NavigationLink {
                    FixedTransitionSettingView()
                } label: {
                    HStack {
                        Text("固定出費 収入").font(.system(size: 16)).foregroundStyle(.black)
                        Spacer()
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
                
                NavigationLink {
                    BudgetSettingView()
                } label: {
                    HStack {
                        Text("予算設定").font(.system(size: 16)).foregroundStyle(.black)
                        Spacer()
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
            }
            
            Section {
                NavigationLink {
                    SelectionView(
                        title: "ダークモード",
                        options: AppThemeType.allCases,
                        selection: $viewModel.appSettings.themeType,
                        displayString: \.displayString
                    )
                } label: {
                    HStack {
                        Text("ダークモード")
                        
                        Spacer()
                        
                        Text(viewModel.appSettings.themeType.displayString).foregroundStyle(.secondary)
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()            }

            Section {
                NavigationLink {
                    BackupSettingView()
                        .background(Color(uiColor: .systemGroupedBackground))
                } label: {
                    HStack {
                        Text("バックアップ")
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
            }

            Section {
                NavigationLink {
                    NotificationSettingView()
                        .background(Color(uiColor: .systemGroupedBackground))
                } label: {
                    HStack {
                        Text("入れ忘れ通知")
                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
            }

            Section {
                NavigationLink {
                    PasscodeSettingView()
                        .background(Color(uiColor: .systemGroupedBackground))
                } label: {
                    HStack {
                        Text("パスコードロック")

                    }
                }
                .ListRowComponentStyle()
                .ListRowStyle()
            }

            
            Section {
                Button {
                    viewModel.editingEditTransitionType = viewModel.appSettings.editTransitionType
                    viewModel.showEditTransitionTypeSheet = true
                } label: {
                    HStack {
                        Text("再入力時の動作")
                        Spacer()
                        Text(viewModel.appSettings.editTransitionType.displayString)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .ListRowComponentStyle()
                .ListRowStyle()
            }
            
            Section {
                Button {
                    viewModel.editingStartMonth = viewModel.appSettings.yearlyStartMonth
                    viewModel.showStartMonthSheet = true
                } label: {
                    HStack {
                        Text("年度の開始月")
                            .font(.system(size: 16)).foregroundStyle(.black)
                            .frame(width: 108, alignment: .leading)
                        Spacer()
                        Text("\(viewModel.appSettings.yearlyStartMonth)月")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .ListRowComponentStyle()
                .ListRowStyle()
                
                Button {
                    viewModel.editingWeeklyStartDay = viewModel.appSettings.weeklyStartDay
                    viewModel.showWeeklyStartDaySheet = true
                } label: {
                    HStack {
                        Text("週の開始日")
                            .font(.system(size: 16)).foregroundStyle(.black)
                            .frame(width: 108, alignment: .leading)
                        Spacer()
                        Text(viewModel.appSettings.weeklyStartDay.displayString)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .ListRowComponentStyle()
                .ListRowStyle()
            }
            
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(24)
        .scrollIndicators(.visible)
        .contentMargins(.top, 8, for: .scrollContent)
        .sheet(isPresented: $viewModel.showEditTransitionTypeSheet) {
            NavigationStack {
                Picker(
                    "再入力時の動作",
                    selection: Binding(
                        get: { viewModel.editingEditTransitionType ?? viewModel.appSettings.editTransitionType },
                        set: { viewModel.editingEditTransitionType = $0 }
                    )                ) {
                        ForEach(EditTransitionType.allCases, id: \.self) { type in
                            Text(type.displayString)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.wheel)
                    .navigationTitle("年度の開始月")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.showEditTransitionTypeSheet = false
                                viewModel.editingEditTransitionType = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                if let value = viewModel.editingEditTransitionType {
                                    viewModel.appSettings.editTransitionType = value
                                }
                                viewModel.showEditTransitionTypeSheet = false
                                viewModel.editingEditTransitionType = nil
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showStartMonthSheet) {
            NavigationStack {
                Picker(
                    "年度の開始月",
                    selection: Binding(
                        get: { viewModel.editingStartMonth ?? viewModel.appSettings.yearlyStartMonth },
                        set: { viewModel.editingStartMonth = $0 }
                    )                ) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)月")
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .navigationTitle("年度の開始月")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.showStartMonthSheet = false
                                viewModel.editingStartMonth = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                if let month = viewModel.editingStartMonth {
                                    viewModel.appSettings.yearlyStartMonth = month
                                }
                                viewModel.showStartMonthSheet = false
                                viewModel.editingStartMonth = nil
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        
        .sheet(isPresented: $viewModel.showWeeklyStartDaySheet) {
            NavigationStack {
                Picker(
                    "週の開始日",
                    selection: Binding(
                        get: { viewModel.editingWeeklyStartDay ?? viewModel.appSettings.weeklyStartDay },
                        set: { viewModel.editingWeeklyStartDay = $0 }
                    )
                ) {
                    ForEach([Weekday.sunday, Weekday.monday], id: \.self) { day in
                        Text(day.displayString)
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .navigationTitle("週の開始日")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.editingWeeklyStartDay = nil
                            viewModel.showWeeklyStartDaySheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let day = viewModel.editingWeeklyStartDay {
                                viewModel.appSettings.weeklyStartDay = day
                            }
                            viewModel.editingWeeklyStartDay = nil
                            viewModel.showWeeklyStartDaySheet = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

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
            SettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
