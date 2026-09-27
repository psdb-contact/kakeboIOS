import SwiftUI

@Observable
final class AppViewModel {
    private let appSettings: AppSettings

    var themeType: AppThemeType {
        get {
            appSettings.themeType
        }
        set {
            appSettings.themeType = newValue
        }
    }

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }
}
