import Observation
import Foundation

@Observable
final class SettingViewModel {
    var appSettings: AppSettings
 
    var showEditTransitionTypeSheet = false
    var editingEditTransitionType: EditTransitionType? = nil
    
    var showStartMonthSheet: Bool = false
    var editingStartMonth: Int? = nil
    
    var showWeeklyStartDaySheet: Bool = false
    var editingWeeklyStartDay: Weekday? = nil
        
    
    init(appSettings: AppSettings)  {
        self.appSettings = appSettings
    }
}
