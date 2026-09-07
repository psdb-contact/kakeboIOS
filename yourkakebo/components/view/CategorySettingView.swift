//
//  CategorySettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftUI
import SwiftData

struct CategorySettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackground.ignoresSafeArea()
            CategorySettingContentView(
                categoryService: appContainer.categoryService
            )
        }
    }
}

private struct CategorySettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let categoryService: CategoryService
    
    @Query(sort: \CategoryModel.sortOrder)
    private var categories: [CategoryModel]
    
    @State private var viewModel: CategorySettingViewModel
    
    init(categoryService: CategoryService) {
        self.categoryService = categoryService
        
        _viewModel = State(
            initialValue: CategorySettingViewModel(
                categoryService: categoryService
            )
        )
    }
    
    private var filteredCategories: [CategoryModel] {
        categories.filter {
            $0.transitionType == viewModel.transitionType
        }
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            if filteredCategories.isEmpty {
                Spacer()
            } else {
                List {
                    ForEach(filteredCategories) { category in
                        categoryCard(category)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 4,
                                    leading: 8,
                                    bottom: 4,
                                    trailing: 8
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onMove(
                        perform: moveCategory
                    )
                }
                .listStyle(.plain)
                .scrollIndicators(.visible)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                transitionTypeSelector
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showingAddCategory = true
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
        .sheet(item: $viewModel.categoryToEdit) { category in
        NavigationStack {
            EditCategorySheet(
                categoryModel: category,
                categoryService: categoryService
            )
        }
        .presentationBackground(Color.modalSheetBackground)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showingAddCategory) {
            NavigationStack {
            EditCategorySheet(
                categoryModel: nil,
                categoryService: categoryService
            )
            }
            .presentationBackground(Color.modalSheetBackground)
            .presentationDragIndicator(.hidden)
        }
        .alert(
            "カテゴリ削除",
            isPresented: Binding(
                get: {
                    viewModel.categoryToDelete != nil
                },
                set: {
                    if !$0 {
                        viewModel.cancelDelete()
                    }
                }
            )
        ) {
            Button("キャンセル", role: .cancel) {
                viewModel.cancelDelete()
            }
            
            Button("削除", role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text(
                "このカテゴリを使用している遊戯履歴のカテゴリが「その他」になります。"
            )
        }
    }
    
    private var transitionTypeSelector: some View {
        TextToggle(
            items: [.init(title: "支出", value: .expense),
                    .init(title: "収入", value:.income)
            ],
            selection: viewModel.transitionType,
            onSelectionChanged: {value in viewModel.transitionType = value}
        )
    }
    
    private func categoryCard(
        _ category: CategoryModel
    ) -> some View {
        HStack {
            Text(category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 0) {
                Button {
                    viewModel.selectCategoryForEditing(category)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                                                .foregroundStyle(Color.iconColor)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderless)
                
                Button {
                    viewModel.selectCategoryForDeletion(category)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                                                .foregroundStyle(Color.iconColor)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.containerColor)
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
    
    private func moveCategory(
        from source: IndexSet,
        to destination: Int
    ) {
        do {
            try viewModel.moveCategory(
                from: source,
                to: destination,
                categories: filteredCategories
            )
        } catch {
            print("カテゴリの並び替えに失敗: \(error)")
        }
    }
    
    private func deleteCategory() {
        do {
            try viewModel.deleteCategory()
        } catch {
            print("カテゴリの削除に失敗: \(error)")
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
        NavigationStack{
            CategorySettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
