//
//  BudgetSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct FixedTransitionSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackground.ignoresSafeArea()
            FixedTransitionSettingContentView(
                fixedTransitionService: appContainer.fixedTransitionService,
                categoryService: appContainer.categoryService
            )
        }
    }
}

private struct FixedTransitionSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let fixedTransitionService: FixedTransitionService
    private let categoryService: CategoryService
    
    @Query
    private var fixedTransitions: [FixedTransitionModel]
    
    @State private var viewModel: FixedTransitionSettingViewModel
    
    init(fixedTransitionService: FixedTransitionService, categoryService: CategoryService) {
        self.fixedTransitionService = fixedTransitionService
        self.categoryService = categoryService
        
        _viewModel = State(initialValue: FixedTransitionSettingViewModel(
        )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            switch viewModel.screenType {
            case .list:
                FixedTransitionListScreen(                )
            case .calendar:
                FixedTransitionCalendarScreen(                )
            }
        }
        .sheet(isPresented: $viewModel.showingAddFixedTransition) {
            NavigationStack {
                EditFixedTransitionSheet(
                    fixedTransition: nil,
                    fixedTransitionService: fixedTransitionService,
                    categoryService: categoryService,
                )
                .presentationBackground(Color.modalSheetBackground)
                .presentationDragIndicator(.hidden)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                IconToggle(
                    items: [
                        .init(icon: "list.bullet", value: .list),
                        .init(icon: "calendar", value: .calendar)
                    ],
                    selection: viewModel.screenType,
                    onSelectionChanged: { value in
                        viewModel.screenType = value;
                    }
                )
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showingAddFixedTransition = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleButton(
        icon: String,
        value: FixedTransitionScreenType
    ) -> some View {
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.screenType = value
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17))
                .frame(
                    width: 40,
                    height: 36
                )
                .foregroundStyle(
                    viewModel.screenType == value
                    ? .primary
                    : .secondary
                )
                .background {
                    if viewModel.screenType == value {
                        Capsule()
                            .fill(.white.opacity(0.35))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

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
        NavigationStack{
            FixedTransitionSettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
