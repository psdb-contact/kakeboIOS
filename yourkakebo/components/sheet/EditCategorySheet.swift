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
        categoryService: CategoryService,
        transitionType: TransitionType
    ) {
        _viewModel = State(
            initialValue: EditCategoryViewModel(
                category: categoryModel,
                categoryService: categoryService,
                transitionType: transitionType
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
        
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
                        Text("カテゴリ名")
                            .font(.system(size: 16)).foregroundStyle(.black)
                            .frame(width: 108, alignment: .leading)
                        TextField(
                            "未入力",
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
                    RoundedRectangle(cornerRadius: 12).fill(Color.container)
                )
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(CategoryColors.all, id: \.self) { hex in
                        Button {
                            viewModel.colorHex = hex
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: hex))
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            isSelectedColor(hex)  ? Color.containerColor : Color.clear,
                                            lineWidth: 3
                                        )
                                }
                                .overlay {
                                    if isSelectedColor(hex) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
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
                let title =  viewModel.category != nil ? "カテゴリ編集" : "新規カテゴリ"
                Text(title)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    save()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button() {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toast(toast: $viewModel.toast)
        .task {
            do {
                try viewModel.load()
            } catch {
                print("カテゴリの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private func isSelectedColor(_ hex: Int) -> Bool {
        viewModel.colorHex == hex
    }
    
    private func save() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            viewModel.toast = .error(error.localizedDescription)
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
                transitionType: .expense
            )
            .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

