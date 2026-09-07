//
//  EditCategorySheet.swift
//  yourkakebo
//

import SwiftUI

struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditCategoryViewModel

    init(
        categoryModel: CategoryModel?,
        categoryService: CategoryService
    ) {
        _viewModel = State(
            initialValue: EditCategoryViewModel(
                category: categoryModel,
                categoryService: categoryService
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {

            // MARK: - Form

            VStack(spacing: 24) {

                // 種類
                VStack(alignment: .leading, spacing: 8) {
                    Picker(
                        "種類",
                        selection: $viewModel.transitionType
                    ) {
                        Text("支出")
                            .tag(TransitionType.expense)

                        Text("収入")
                            .tag(TransitionType.income)
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack {
                    HStack {
                        Text("カテゴリ")
                            .font(.system(size: 16)).foregroundStyle(.black)
                            .frame(width: 108, alignment: .leading)
                        TextField(
                            "",
                            text: $viewModel.categoryName
                        )
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.plain)
                        .frame(height: 52)
                    }
                    .padding(.leading, 12)

                }
                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.container)
                                )

                // 色
                /*
                ForEach(categoryColors, id: \.self) { colorHex in
                    Button {
                        viewModel.colorHex = colorHex
                    } label: {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 44, height: 44)
                    }
                }
                 */

                Spacer()
            }
            .padding(20)
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
    }

    private func save() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            print("カテゴリ保存に失敗しました: \(error)")
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
        NavigationStack {
            EditCategorySheet(
                categoryModel: nil,
                categoryService: appContainer.categoryService,
            )
            .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

