import SwiftUI

final class SettingModel {
    private let defaults: UserDefaults

    private enum Key {
        static let isFirstLaunch = "isFirstLaunch"
        static let confirmWhenDelete = "confirmWhenDelete"
        static let backupDate = "backupDate"
        static let appLaunchCount = "appLaunchCount"
        static let lastReviewRequestAt = "lastReviewRequestAt"
        static let themeType = "themeType"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isFirstLaunch: Bool {
        get {
            if defaults.object(forKey: Key.isFirstLaunch) == nil {
                return true
            }

            return defaults.bool(forKey: Key.isFirstLaunch)
        }
        set {
            defaults.set(newValue, forKey: Key.isFirstLaunch)
        }
    }

    var confirmWhenDelete: Bool {
        get {
            if defaults.object(forKey: Key.confirmWhenDelete) == nil {
                return true
            }

            return defaults.bool(forKey: Key.confirmWhenDelete)
        }
        set {
            defaults.set(newValue, forKey: Key.confirmWhenDelete)
        }
    }

    var backupDate: String? {
        get {
            defaults.string(forKey: Key.backupDate)
        }
        set {
            defaults.set(newValue, forKey: Key.backupDate)
        }
    }

    var appLaunchCount: Int {
        get {
            defaults.integer(forKey: Key.appLaunchCount)
        }
        set {
            defaults.set(newValue, forKey: Key.appLaunchCount)
        }
    }

    var lastReviewRequestAt: String? {
        get {
            defaults.string(forKey: Key.lastReviewRequestAt)
        }
        set {
            defaults.set(newValue, forKey: Key.lastReviewRequestAt)
        }
    }

    var themeType: AppThemeType {
        get {
            guard let rawValue = defaults.string(forKey: Key.themeType),
                  let themeType = AppThemeType(rawValue: rawValue) else {
                return .system
            }

            return themeType
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.themeType)
        }
    }

    var swiftUIThemeMode: ColorScheme? {
        switch themeType {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
