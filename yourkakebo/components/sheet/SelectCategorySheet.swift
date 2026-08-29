
//
//  CategorySelectView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct SelectCategorySheet: View {
    @Environment(AppContainer.self)
    private var appContainer
    private var usedCategories: [CategoryModel]
    
    let selectedDate: Date
    
    init(usedCategories: [CategoryModel], selectedDate: Date ) {
        self.usedCategories = usedCategories
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        SelectCategoryContentSheet(
            categoryService: appContainer.categoryService,
            transitionService: appContainer.transitionService,
            usedCategories: self.usedCategories,
            selectedDate: self.selectedDate
        )
    }
}

private struct SelectCategoryContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let categoryService: CategoryService
    private let transitionService: TransitionService
    
    private let usedCategories: [CategoryModel]
    let selectedDate: Date
    
    @State private var viewModel: SelectCategoryViewModel
    
    init(categoryService: CategoryService, transitionService: TransitionService, usedCategories: [CategoryModel], selectedDate: Date) {
        self.categoryService = categoryService
        self.transitionService = transitionService
        self.usedCategories = usedCategories
        self.selectedDate = selectedDate
        
        _viewModel = State(initialValue: SelectCategoryViewModel(categoryService: categoryService, transitionService: transitionService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            HStack {
                Button("キャンセル") {
                    dismiss()
                }
                Spacer()
                Text(
                    "カテゴリ追加"
                )
                .font(.system(size: 18, weight: .semibold))
                
                Spacer()

                .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            
            Divider()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.categoriesData) {
                        item in
                        SelectCategoryForm(
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

struct SelectCategoryForm : View {
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
                Image(systemName: isUsed ? "checkmark" : "plus")                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(isUsed)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(
            color: .black.opacity(0.05),
            radius: 8,
            y: 4
        )
    }
}
