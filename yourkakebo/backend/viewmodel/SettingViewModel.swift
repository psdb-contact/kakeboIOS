import Observation

@Observable
final class SettingViewModel {

    private let appSettings: AppSettings

    var themeType: AppThemeType {
        didSet {
            appSettings.themeType = themeType
        }
    }

    var confirmWhenDelete: Bool {
        didSet {
            appSettings.confirmWhenDelete = confirmWhenDelete
        }
    }

    var backupDate: String? {
        appSettings.backupDate
    }

    var appLaunchCount: Int {
        appSettings.appLaunchCount
    }

    var lastReviewRequestAt: String? {
        appSettings.lastReviewRequestAt
    }

    var isFirstLaunch: Bool {
        appSettings.isFirstLaunch
    }

    init(appSettings: AppSettings) {
        self.appSettings = appSettings

        self.themeType = appSettings.themeType
        self.confirmWhenDelete = appSettings.confirmWhenDelete
    }
}
