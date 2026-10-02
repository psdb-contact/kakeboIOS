//
//  NotificationView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import SwiftUI

struct NotificationView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackground.ignoresSafeArea()
            NotificationContentView(appSettings: appContainer.appSettings, notificationService: appContainer.notificationService)
        }
    }
}

private struct NotificationContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appSettings: AppSettings
    
    @State private var viewModel: NotificationViewModel
    
    init(appSettings: AppSettings, notificationService: NotificationService) {
        self.appSettings = appSettings
        
        _viewModel = State(initialValue: NotificationViewModel(appSettings: appSettings, notificationService: notificationService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ScrollView {
            VStack(spacing: 12) {
                VStack {
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
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
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
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        Button {
                            viewModel.isShowingTimePicker = true
                        }
                        label: {
                            Text("通知時刻")
                            Spacer()
                            Text(  String(
                                format: "%02d:%02d",
                                appSettings.notificationTime / 60,
                                appSettings.notificationTime % 60
                            ))
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .sheet(isPresented: $viewModel.isShowingTimePicker) {
            NavigationStack {
                DatePicker(
                    "通知時刻",
                    selection: Binding(
                        get: {
                            let minutes = viewModel.appSetting.notificationTime
                            
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
                            
                            viewModel.appSetting.notificationTime =
                            (components.hour ?? 0) * 60
                            + (components.minute ?? 0)
                            
                            if viewModel.appSetting.isNotificationOn {
                                Task {
                                    await viewModel.updateNotifications()
                                }
                            }
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .navigationTitle("通知時刻")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完了") {
                            viewModel.isShowingTimePicker = false
                        }
                    }
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
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
            NotificationView()
                .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
