//
//  NotificationView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import SwiftUI

struct NotificationSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        NotificationSettingContentView(appSettings: appContainer.appSettings, notificationService: appContainer.notificationService)
    }
}

private struct NotificationSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appSettings: AppSettings
    
    @State private var viewModel: NotificationSettingViewModel
    
    init(appSettings: AppSettings, notificationService: NotificationService) {
        self.appSettings = appSettings
        
        _viewModel = State(initialValue: NotificationSettingViewModel(appSettings: appSettings, notificationService: notificationService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        List {
            Section {
                Toggle("入れ忘れ通知", isOn: $viewModel.appSetting.isNotificationOn)
                    .onChange(of: viewModel.appSetting.isNotificationOn) { _, isOn in
                        Task {
                            if isOn {
                                try? await viewModel.enableNotifications()
                            } else {
                                viewModel.disableNotification()
                            }
                        }
                    }
                    .ListRowComponentStyle()
                    .ListRowStyle()
                if(viewModel.appSetting.isNotificationOn) {
                    NavigationLink{
                        NotificationDaysSelectView(selection: $viewModel.appSetting.notificationDays) { day, isSelected in
                            Task {
                                await viewModel.updateNotificationDay(
                                    day,
                                    isSelected: isSelected
                                )
                            }
                        }
                    } label : {
                        HStack {
                            Text("曜日")
                            Spacer()
                            Text(viewModel.appSetting.notificationDays.displayText)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .ListRowComponentStyle()
                    .ListRowStyle()
                    
                    Button {
                        viewModel.editingNotificationTime = viewModel.appSetting.notificationTime
                        viewModel.isShowingTimePicker = true                    }
                    label: {
                        Text("通知時刻")
                        Spacer()
                        Text(  String(
                            format: "%02d:%02d",
                            appSettings.notificationTime / 60,
                            appSettings.notificationTime % 60
                        ))
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                    .buttonStyle(.plain)
                    .ListRowComponentStyle()
                    .ListRowStyle()
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(24)
        .scrollIndicators(.visible)
        .contentMargins(.top, 8, for: .scrollContent)
        .sheet(isPresented: $viewModel.isShowingTimePicker) {
            NavigationStack {
                DatePicker(
                    "通知時刻",
                    selection: Binding(
                        get: {
                            let minutes = viewModel.editingNotificationTime
                            ?? viewModel.appSetting.notificationTime
                            
                            return Calendar.current.date(
                                bySettingHour: minutes / 60,
                                minute: minutes % 60,
                                second: 0,
                                of: Date()
                            ) ?? Date()
                        },
                        set: { date in
                            let components = Calendar.current.dateComponents(
                                [.hour, .minute],
                                from: date
                            )
                            
                            viewModel.editingNotificationTime =
                            (components.hour ?? 0) * 60
                            + (components.minute ?? 0)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .navigationTitle("通知時刻")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.isShowingTimePicker = false
                            viewModel.editingNotificationTime = nil
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let minutes = viewModel.editingNotificationTime {
                                viewModel.appSetting.notificationTime = minutes
                                
                                if viewModel.appSetting.isNotificationOn {
                                    Task {
                                        await viewModel.updateNotifications()
                                    }
                                }
                            }
                            
                            viewModel.isShowingTimePicker = false
                            viewModel.editingNotificationTime = nil
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
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
        NavigationStack {
            NotificationSettingView()
                .background(Color(uiColor: .systemGroupedBackground))
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
