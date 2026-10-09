import Observation
import Foundation

@Observable
final class SettingViewModel {
    var appSettings: AppSettings
    
    init(appSettings: AppSettings)  {
        self.appSettings = appSettings
    }
}
