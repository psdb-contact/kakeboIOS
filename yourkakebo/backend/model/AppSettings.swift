import SwiftUI
import Observation

@Observable
final class AppSettings {

    private let defaults: UserDefaults

    private enum Key {
        static let isFirstLaunch = "isFirstLaunch"
        static let confirmWhenDelete = "confirmWhenDelete"
        static let backupDate = "backupDate"
        static let appLaunchCount = "appLaunchCount"
        static let lastReviewRequestAt = "lastReviewRequestAt"
        static let themeType = "themeType"
    }

    var isFirstLaunch: Bool {
        didSet {
            defaults.set(isFirstLaunch, forKey: Key.isFirstLaunch)
        }
    }

    var confirmWhenDelete: Bool {
        didSet {
            defaults.set(confirmWhenDelete, forKey: Key.confirmWhenDelete)
        }
    }

    var backupDate: Date? {
        didSet {
            defaults.set(backupDate, forKey: Key.backupDate)
        }
    }

    var appLaunchCount: Int {
        didSet {
            defaults.set(appLaunchCount, forKey: Key.appLaunchCount)
        }
    }

    var lastReviewRequestAt: String? {
        didSet {
            defaults.set(lastReviewRequestAt, forKey: Key.lastReviewRequestAt)
        }
    }

    var themeType: AppThemeType {
        didSet {
            defaults.set(themeType.rawValue, forKey: Key.themeType)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if defaults.object(forKey: Key.isFirstLaunch) == nil {
            self.isFirstLaunch = true
        } else {
            self.isFirstLaunch = defaults.bool(
                forKey: Key.isFirstLaunch
            )
        }

        if defaults.object(forKey: Key.confirmWhenDelete) == nil {
            self.confirmWhenDelete = true
        } else {
            self.confirmWhenDelete = defaults.bool(
                forKey: Key.confirmWhenDelete
            )
        }

        self.backupDate = defaults.object(
            forKey: Key.backupDate
        ) as? Date

        self.appLaunchCount = defaults.integer(
            forKey: Key.appLaunchCount
        )

        self.lastReviewRequestAt = defaults.string(
            forKey: Key.lastReviewRequestAt
        )

        if let rawValue = defaults.string(forKey: Key.themeType),
           let themeType = AppThemeType(rawValue: rawValue) {
            self.themeType = themeType
        } else {
            self.themeType = .system
        }
    }
}

extension AppSettings {

    static var preview: AppSettings {
        let defaults = UserDefaults(
            suiteName: "yourkakebo.preview"
        )!

        defaults.removePersistentDomain(
            forName: "yourkakebo.preview"
        )

        let settings = AppSettings(
            defaults: defaults
        )

        settings.isFirstLaunch = false
        settings.confirmWhenDelete = true
        settings.appLaunchCount = 10
        settings.themeType = .system

        return settings
    }
}
