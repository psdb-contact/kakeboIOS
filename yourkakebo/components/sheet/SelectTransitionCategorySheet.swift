
//
//  CategorySelectView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct SelectTransitionCategorySheet: View {
    @Environment(AppContainer.self)
    private var appContainer
    private var usedExpenseIds: [UUID]
    private var usedIncomeIds: [UUID]
    
    let onSave: (TransitionModel) -> Void
    
    private let transitionPeriod: TransitionPeriod
    
    init(usedExpenseIds: [UUID], usedIncomeIds: [UUID], transitionPeriod: TransitionPeriod, onSave: @escaping (TransitionModel) -> Void ) {
        self.usedExpenseIds = usedExpenseIds
        self.usedIncomeIds = usedIncomeIds
        self.transitionPeriod = transitionPeriod
        
        self.onSave = onSave
    }
    
    var body: some View {
        SelectTransitionCategoryContentSheet(
            categoryService: appContainer.categoryService,
            transitionService: appContainer.transitionService,
            usedExpenseIds: self.usedExpenseIds,
            usedIncomeIds: self.usedIncomeIds,
            transitionPeriod: self.transitionPeriod,
            onSave: self.onSave
        )
    }
}

private struct SelectTransitionCategoryContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let categoryService: CategoryService
    private let transitionService: TransitionService
    
    let onSave: (TransitionModel) -> Void

    @State private var viewModel: SelectTransitionCategoryViewModel
    
    init(categoryService: CategoryService, transitionService: TransitionService,usedExpenseIds: [UUID], usedIncomeIds: [UUID], transitionPeriod: TransitionPeriod, onSave: @escaping (TransitionModel) -> Void) {
        self.categoryService = categoryService
        self.transitionService = transitionService
        
        self.onSave = onSave
        
        _viewModel = State(initialValue: SelectTransitionCategoryViewModel(categoryService: categoryService, transitionService: transitionService, usedExpenseIds: usedExpenseIds,usedIncomeIds:  usedIncomeIds, transitionPeriod: transitionPeriod ))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.categoriesData) {
                        item in
                        SelectTransitionCategoryForm(
                            category: item.category,
                            isUsed: item.isUsed,
                            onSelect: { viewModel.selectedCategory = item.category }
                        )
                    }
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .principal) {
                TextToggle(
                    items: [
                        .init(title: "支出", value: .expense),
                        .init(title: "収入", value: .income)
                    ],
                    selection: viewModel.transitionPeriod.type,
                    onSelectionChanged: { value in
                        viewModel.transitionPeriod = TransitionPeriod(type: value, date: viewModel.transitionPeriod.date)
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.selectedCategory) {category in
            AddTransitionView(category: category, transitionPeriod: viewModel.transitionPeriod) { updatedTransition in
                onSave(updatedTransition)
            }
            .background(Color.modalSheetBackground)
        }
        .task(id: viewModel.transitionPeriod){
            do {
                try viewModel.load(viewModel.transitionPeriod)
            } catch {
                print("Ctegoryの読み込みに失敗しました: \(error)")
            }
        }
    }
}

struct SelectTransitionCategoryForm : View {
    let category: CategoryModel
    let isUsed: Bool
    let onSelect: () -> Void
    
    init(
        category: CategoryModel,
        isUsed: Bool,
        onSelect: @escaping () -> Void
    ){
        self.category = category
        self.isUsed = isUsed
        self.onSelect = onSelect
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(category.categoryName)
                .font(.system(size: 18))
                .frame(
                    width: 92,
                    alignment: .leading
                )
            Spacer()
            Button {
                onSelect()
            } label: {
                Image(systemName: isUsed ? "checkmark" : "plus")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(isUsed)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
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
        NavigationStack {
            SelectTransitionCategorySheet(
                usedExpenseIds: [],
                usedIncomeIds: [],
                transitionPeriod: TransitionPeriod(type: .expense, date: Date()),
                onSave: {item in}
            )
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

