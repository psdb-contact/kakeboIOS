//
//  ContentView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            TabView {
                NavigationStack {
                    EditTransitionView()
                }
                .tabItem {
                    Label("入力", systemImage: "globe")
                }
                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                
                NavigationStack {
                    ReportView()
                }.tabItem {
                    Label( "レポート", systemImage: "calendar")
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for:
            CategoryModel.self,
        TransitionModel.self,
        BudgetModel.self,
        TemplateModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let appContainer = AppContainer(
        modelContext: container.mainContext
    )
    
    ContentView()
        .modelContainer(container)
        .environment(appContainer)
}
