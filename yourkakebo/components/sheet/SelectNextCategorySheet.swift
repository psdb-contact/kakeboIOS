
//
//  CategorySelectView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct SelectNextCategorySheet: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    let current: CategoryModel
    let categories: [CategoryModel]
    
    let onSelect: (CategoryModel) -> Void
    
    var body: some View {
        SelectNextCategoryContentSheet(
            current: current,
            categories: categories,
            onSelect: onSelect
        )
    }
}

private struct SelectNextCategoryContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let current: CategoryModel
    private let categories: [CategoryModel]
    
    private let onSelect: (CategoryModel) -> Void
        
    init(current: CategoryModel,  categories: [CategoryModel], onSelect: @escaping (CategoryModel) -> Void) {
        self.current = current
        self.categories = categories
        
        self.onSelect = onSelect
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(categories) {
                        item in
                        SelectNextCategoryForm(
                            category: item,
                            isUsed: item.categoryId == current.categoryId,
                            onSelect: { category in
                                onSelect(category)
                                dismiss()
                            }
                        )
                    }
                }
            }
            .padding(.top, 8)
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
                    ""
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SelectNextCategoryForm : View {
    let category: CategoryModel
    let isUsed: Bool
    let onSelect: (CategoryModel) -> Void
    
    init(
        category: CategoryModel,
        isUsed: Bool,
        onSelect: @escaping (CategoryModel) -> Void
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
                onSelect(category)
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
            SelectTemplateCategorySheet(
                usedCategories: []
            )
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
