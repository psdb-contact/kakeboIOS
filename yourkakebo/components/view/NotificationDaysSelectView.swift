//
//  NotificationDaysView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import SwiftUI

struct NotificationDaysSelectView: View {
    @Binding var selection: Set<Weekday>
    let onSelectionChanged: (Weekday, Bool) -> Void
    
    var body: some View {
        ZStack{
            Color.secondBackground.ignoresSafeArea()
            ScrollView {
                ForEach(Weekday.allCases, id: \.self) {day in
                    Toggle(
                        day.displayName,
                        isOn: Binding(
                            get: {
                                selection.contains(day)
                            },
                            set: { isSelected in
                                
                                if isSelected {
                                    selection.insert(day)
                                } else {
                                    selection.remove(day)
                                }
                                
                                onSelectionChanged(day, isSelected)
                            }
                        )
                    )
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
