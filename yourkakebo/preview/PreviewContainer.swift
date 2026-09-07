//
//  PreviewContainer.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//
import SwiftData

enum PreviewContainer {

    static func make() -> (
        container: ModelContainer,
        appContainer: AppContainer
    ) {
        let container = try! ModelContainer(
            for:
                CategoryModel.self,
            TransitionModel.self,
            BudgetModel.self,
            TemplateModel.self,
            FixedTransitionModel.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )

        let appContainer = AppContainer(
            modelContext: container.mainContext
        )

        return (container, appContainer)
    }
}
