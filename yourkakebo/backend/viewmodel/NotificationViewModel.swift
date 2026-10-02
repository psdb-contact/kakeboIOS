//
//  NotificationViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import Observation
import Foundation

@Observable
final class NotificationViewModel {
    var appSetting: AppSettings
    private let notificationService: NotificationService
    
    var toast: ToastData?
    
    var isShowingTimePicker: Bool = false
    
    init(appSettings: AppSettings, notificationService: NotificationService) {
        self.appSetting = appSettings
        self.notificationService = notificationService
    }
    
    func enableNotifications() async throws {
        do {
            try await notificationService.requestPermission()
            
            try await notificationService.scheduleReminders(
                time: appSetting.notificationTime,
                weekdays: appSetting.notificationDays
            )
            
        } catch {
            appSetting.isNotificationOn = false
        }
    }
    
    func updateNotifications() async {
        guard appSetting.isNotificationOn else {
        return
        }
        
        do {
            notificationService.cancelReminders()
            
            try await notificationService.scheduleReminders(
                time: appSetting.notificationTime,
                weekdays: appSetting.notificationDays
            )
        } catch {
            toast = .error("処理に失敗しました。")
        }
    }
    
    func updateNotificationDay(_ day: Weekday, isSelected: Bool) async {
        if isSelected {
            do {
                try await notificationService.scheduleReminder(time: appSetting.notificationTime, weekday: day)
            } catch {
                toast = .error("処理に失敗しました。")
            }
        } else {
            notificationService.cancelReminder(
                      for: day
                  )
        }
    }
    
    func disableNotification() {
        notificationService.cancelReminders()
    }
}
