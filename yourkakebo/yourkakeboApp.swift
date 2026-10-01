//
//  yourkakeboApp.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftUI
import SwiftData

@main
struct YourKakeboApp: App {
    @Environment(\.scenePhase)
    private var scenePhase
    
    let modelContainer: ModelContainer
    let appContainer: AppContainer
        
    init() {
        do {
            let container = try ModelContainer(
                for:
                    CategoryModel.self,
                    TransitionModel.self,
                    BudgetModel.self,
                    TemplateModel.self
            )
            
            self.modelContainer = container
            
            self.appContainer = AppContainer(
                modelContext: container.mainContext
            )
        } catch {
            fatalError(
                "ModelContainerの作成に失敗しました: \(error)"
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let context = ModelContext(modelContainer)
                    
                    InitialCategorySeeder.seedIfNeeded(
                        appSettings: appContainer.appSettings,
                        context: context
                    )
                    InitialTemplateSeeder.seedIfNeeded(
                        appSettings: appContainer.appSettings,
                        context: context
                    )
                    appContainer.appSettings.isFirstLaunch = false
                }
                .preferredColorScheme(appContainer.appSettings.themeType.swiftUIThemeMode)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
        .modelContainer(modelContainer)
        .environment(appContainer)
        .onChange(of: scenePhase) {
             guard scenePhase == .background else { return }

             do {
                 try appContainer.backupService.importInternalBackup()
                 appContainer.appSettings.backupDate = Date()
             } catch {
                 print("自動バックアップに失敗しました: \(error)")
             }
         }
    }
}
