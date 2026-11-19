
import SwiftUI

func formattedMonth(_ date: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy / M"
    
    return formatter.string(
        from: date
    )
}

func formattedAmount(
    _ amount: Int?,
    nilText: String = "未設定"
) -> String {
    guard let amount else {
        return nilText
    }

    return "\(amount.formatted())円"
}
