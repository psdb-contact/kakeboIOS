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
        CategorySettingContentView(
            categoryService: appContainer.categoryService
        )
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
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
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
        .sheet(item: $viewModel.categoryToEdit) { category in
            EditCategorySheet(
                categoryModel: category,
                categoryService: categoryService
            )
            .presentationDetents([.fraction(0.8)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showingAddCategory) {
            EditCategorySheet(
                categoryModel: nil,
                categoryService: categoryService
            )
            .presentationDetents([.fraction(0.8)])
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
        HStack(spacing: 0) {
            Button {
                viewModel.transitionType = .expense
            } label: {
                Text("支出")
                    .foregroundStyle(
                        viewModel.transitionType == .expense
                        ? Color.white
                        : Color(
                            red: 0.27,
                            green: 0.27,
                            blue: 0.27
                        )
                    )
                    .frame(width: 120, height: 44)
                    .background(
                        viewModel.transitionType == .expense
                        ? Color(
                            red: 0.27,
                            green: 0.27,
                            blue: 0.27
                        )
                        : Color.white
                    )
            }

            Button {
                viewModel.transitionType = .income
            } label: {
                Text("収入")
                    .foregroundStyle(
                        viewModel.transitionType == .income
                        ? Color.white
                        : Color(
                            red: 0.27,
                            green: 0.27,
                            blue: 0.27
                        )
                    )
                    .frame(width: 120, height: 44)
                    .background(
                        viewModel.transitionType == .income
                        ? Color(
                            red: 0.27,
                            green: 0.27,
                            blue: 0.27
                        )
                        : Color.white
                    )
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    Color(
                        red: 0.93,
                        green: 0.94,
                        blue: 0.95
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 3
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

            HStack(spacing: 16) {
                Button {
                    viewModel.selectCategoryForEditing(category)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                        .frame(width: 44, height: 44)
                }

                Button {
                    viewModel.selectCategoryForDeletion(category)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                        .frame(width: 44, height: 44)
                }

                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        Color(
                            red: 0.33,
                            green: 0.33,
                            blue: 0.33
                        )
                    )
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
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
