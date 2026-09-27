//
//  AddTransitionView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/20.
//

import SwiftUI

struct AddTransitionView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var selectedDate: Date
    
    var body: some View {
            AddTransitionContentView(
                transitionService: appContainer.transitionService,
                categoryService: appContainer.categoryService,
                selectedDate: selectedDate
            )
    }
}

private struct AddTransitionContentView: View {
    @State private var viewModel: AddTransitionViewModel
    
    init(transitionService: TransitionService, categoryService: CategoryService, selectedDate: Date) {
        _viewModel = State(initialValue: AddTransitionViewModel(
            transitionService: transitionService,
            categoryService: categoryService,
            selectedDate: selectedDate
        ))
            
    }
    
    var body: some View {
        VStack{
            
        }
    }
}

import SwiftData

#Preview {
    PreviewContent()
}

@MainActor
private struct PreviewContent: View {
    
    private let container: ModelContainer
    private let appContainer: AppContainer
    
    init() {
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
        
        let context = container.mainContext
        
        PreviewSeeder.seed(
            context: context
        )
        
        self.container = container
        self.appContainer = AppContainer(
            modelContext: context
        )
    }
    
    var body: some View {
        AddTransitionView(selectedDate: Calendar.current.startOfDay(for: Date()))
            .modelContainer(container)
            .environment(appContainer)
    }
}
