//
//  NotificationView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/01.
//

import SwiftUI

struct NotificationView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        NotificationContentView(appSettings: appContainer.appSettings)
    }
}

private struct NotificationContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appSettings: AppSettings
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }
    
    var body: some View {
            
    }
}
