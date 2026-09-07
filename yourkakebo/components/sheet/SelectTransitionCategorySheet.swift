
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
    private var usedCategories: [CategoryModel]
    
    let selectedDate: Date
    
    init(usedCategories: [CategoryModel], selectedDate: Date ) {
        self.usedCategories = usedCategories
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        SelectTransitionCategoryContentSheet(
            categoryService: appContainer.categoryService,
            transitionService: appContainer.transitionService,
            usedCategories: self.usedCategories,
            selectedDate: self.selectedDate
        )
    }
}

private struct SelectTransitionCategoryContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let categoryService: CategoryService
    private let transitionService: TransitionService
    
    private let usedCategories: [CategoryModel]
    let selectedDate: Date
    
    @State private var viewModel: SelectTransitionCategoryViewModel
    
    init(categoryService: CategoryService, transitionService: TransitionService, usedCategories: [CategoryModel], selectedDate: Date) {
        self.categoryService = categoryService
        self.transitionService = transitionService
        self.usedCategories = usedCategories
        self.selectedDate = selectedDate
        
        _viewModel = State(initialValue: SelectTransitionCategoryViewModel(categoryService: categoryService, transitionService: transitionService))
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
                            onSelect: { save(
                                category: item.category
                            )
                                dismiss()
                            }
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
                Text(
                    "カテゴリ追加"
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task{
            do {
                try viewModel.load(usedCategories: self.usedCategories)
            } catch {
                print("Ctegoryの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private func save(category: CategoryModel) {
        do {
            try viewModel.save(
                transition:
                    TransitionModel(amount: 0, transitionType: category.transitionType, transitionDate: selectedDate, createdAt: Date.now, category: category)
            )
        } catch {
            
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
                .font(.system(size: 16))
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
                usedCategories: [],
                selectedDate: Calendar.current.startOfDay(for: Date())
            )
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

