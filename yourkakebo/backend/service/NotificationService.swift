//
//  NotificationService.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import Foundation
import UserNotifications

final class NotificationService {

    private let center = UNUserNotificationCenter.current()

    func requestPermission() async throws {
        try await center.requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }

    func scheduleReminders(
        time: Int,
        weekdays: Set<Weekday>
    ) async throws {

        let content = UNMutableNotificationContent()
        content.title = "あなたの家計簿"
        content.body = "今日の収支を入力"
        content.sound = .default

        let hour = time / 60
        let minute = time % 60

        for weekday in weekdays {
            var components = DateComponents()
            components.weekday = weekday.rawValue
            components.hour = hour
            components.minute = minute

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: weekday),
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }
    }
    
    func scheduleReminder(
        time: Int,
        weekday: Weekday
    ) async throws {

        let content = UNMutableNotificationContent()
        content.title = "あなたの家計簿"
        content.body = "今日の収支を入力"
        content.sound = .default

        var components = DateComponents()
        components.weekday = weekday.rawValue
        components.hour = time / 60
        components.minute = time % 60

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: weekday),
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelReminders() {
        let identifiers = Weekday.allCases.map {
            "kakebo-reminder-\($0.rawValue)"
        }

        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
    
    func cancelReminder(for weekday: Weekday) {
         center.removePendingNotificationRequests(
             withIdentifiers: [
                 notificationIdentifier(for: weekday)
             ]
         )
     }
    
    private func notificationIdentifier(
          for weekday: Weekday
      ) -> String {
          "kakebo-reminder-\(weekday.rawValue)"
      }
}
