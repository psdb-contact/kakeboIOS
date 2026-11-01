//
//  EditTransitionSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/17.
//

import SwiftUI

struct AddTransitionOnCalendarView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    let selectedDate: Date
    let onSave: (TransitionModel) -> Void
    
    init(selectedDate: Date, onSave: @escaping (TransitionModel) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
    }
    
    var body: some View {
        AddTransitionOnCalendarContentView(
            transitionService: appContainer.transitionService,
            categoryService: appContainer.categoryService,
            selectedDate: self.selectedDate,
            onSave: self.onSave
        )
    }
}

private struct AddTransitionOnCalendarContentView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    var onSave: (TransitionModel) -> Void
    
    @State private var viewModel: AddTransitionOnCalendarViewModel
    @FocusState private var isFocused: Bool
    
    init(transitionService: TransitionService, categoryService: CategoryService, selectedDate: Date, onSave: @escaping (TransitionModel) -> Void) {
        self.onSave = onSave
        
        _viewModel = State(
            initialValue: AddTransitionOnCalendarViewModel(
                transitionService: transitionService,
                categoryService: categoryService,
                selectedDate: selectedDate
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack {
            ScrollView {
                VStack(spacing: 24) {
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
                            TextField(
                                "金額",
                                text: Binding(
                                    get: {
                                        viewModel.amountInput ?? ""
                                    },
                                    set: { newValue in
                                        let value = String(
                                            newValue
                                                .filter { $0.isNumber }
                                                .prefix(6)
                                        )
                                        viewModel.amountInput = value.isEmpty ? nil : value
                                    }
                                )
                            )
                            .keyboardType(.numberPad)
                            .font(.system(size: 18))
                            .padding(.trailing, 16)
                            .frame(height: 52)
                            .focused($isFocused)
                            if(viewModel.amountInput != nil) {
                                Button {
                                    viewModel.amountInput = nil
                                }  label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.trailing, 16)
                                .buttonStyle(.plain)
                            }
                            
                        }
                        .padding(.leading, 12)
                        Divider()
                            .padding(.horizontal, 12)
                        HStack {
                            Button {
                                viewModel.showCategorySheet = true
                            } label: {
                                HStack {
                                    Text("カテゴリ")
                                        .font(.system(size: 16)).foregroundStyle(.black)
                                        .frame(width: 108, alignment: .leading)
                                    Spacer()
                                    Text(viewModel.category?.categoryName ?? "未選択")
                                        .font(.system(size: 16))
                                        .foregroundStyle(
                                            viewModel.category == nil
                                            ? Color(uiColor: .placeholderText)
                                            : Color.primary
                                        )
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                            }
                        }
                        
                    }
                    .padding(.vertical, 8)
                      .background(
                          RoundedRectangle(cornerRadius: 12)
                              .fill(Color.container)
                      )
                }
            }
        }
        .padding(20)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                SubmitButton {
                    save()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $viewModel.showCategorySheet) {
             NavigationStack {
                 Picker(
                     "カテゴリ",
                     selection: Binding(
                         get: {
                             viewModel.category?.categoryId
                         },
                         set: { newCategoryId in
                             viewModel.editingCategory = viewModel.categories.first {
                                 $0.categoryId == newCategoryId
                             }
                         }
                     )
                 ) {
                     ForEach(viewModel.categories,  id: \.categoryId) { category in
                         Text(category.categoryName)
                             .tag(Optional(category.categoryId))
                     }
                 }
                 .pickerStyle(.wheel)
                 .navigationTitle("カテゴリ")
                 .navigationBarTitleDisplayMode(.inline)
                 .toolbar {
                     ToolbarItem(placement: .topBarLeading) {
                         Button {
                             viewModel.showCategorySheet = false
                         } label: {
                             Image(systemName: "xmark")
                         }
                     }
                     
                     ToolbarItem(placement: .topBarTrailing) {
                         Button {
                             if let category = viewModel.editingCategory {
                                 viewModel.category = category
                             }
                             viewModel.showCategorySheet = false
                         } label: {
                             Image(systemName: "checkmark")
                         }
                     }
                 }
             }
             .presentationDetents([.medium])
         }
        .task {
            isFocused = true
            try? viewModel.load()
        }
    }
    
    private func save() {
        do {
            let savedTransition = try viewModel.save()
            onSave(savedTransition)
            
            dismiss()
        } catch {
            viewModel.toast = .error(error.localizedDescription)
            print("収支の保存に失敗しました: \(error)")
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
            AddTransitionOnCalendarView(
                selectedDate: Date(),
                onSave: {transition in return}
            )
            .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

