
import SwiftUI

func formattedMonth(_ date: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy / M"
    
    return formatter.string(
        from: date
    )
}
