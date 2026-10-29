//
//  AssignCategorySheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/29.
//

import SwiftUI
import SwiftData

struct AssignTransitionCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \CategoryModel.sortOrder)
    private var categories: [CategoryModel]
    
    private var filteredCategories: [CategoryModel] {
        categories.filter {
            $0.transitionType == transitionType
        }
    }
    
    let onSave: (CategoryModel) -> Void
    let transitionType: TransitionType
    
    init(transitionType: TransitionType, onSave: @escaping (CategoryModel) -> Void) {
        self.transitionType = transitionType
        self.onSave = onSave
    }
    
    var body: some View {
        ScrollView {
            ForEach(filteredCategories) {item in
                AssignTransitionCategoryForm(category: item, onSelect: {
                    onSave(item)
                    dismiss()
                })
            }
        }
    }
}

private struct AssignTransitionCategoryForm: View {
    let category: CategoryModel
    let onSelect: () -> Void
    
    init(category: CategoryModel, onSelect: @escaping () -> Void) {
        self.category = category
        self.onSelect = onSelect
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(category.categoryName)
                .font(.system(size: 18))
            Spacer()
            Button {
                onSelect()
            } label: {
                Image(systemName:"checkmark")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
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
            AssignTransitionCategorySheet(
                transitionType: .expense,
                onSave: {item in}
            )
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
