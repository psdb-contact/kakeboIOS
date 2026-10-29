//
//  EditTransitionSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/17.
//

import SwiftUI

struct AddTransitionView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var category: CategoryModel
    var transitionPeriod: TransitionPeriod
    var onSave: (TransitionModel) -> Void

    
    init(category: CategoryModel, transitionPeriod: TransitionPeriod, onSave: @escaping (TransitionModel) -> Void) {
        self.category = category
        self.transitionPeriod = transitionPeriod
        self.onSave = onSave
    }
    
    var body: some View {
            AddTransitionContentView(
                transitionService: appContainer.transitionService,
                category: category,
                transitionPeriod: transitionPeriod,
                onSave: onSave
            )
    }
}

private struct AddTransitionContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: AddTransitionViewModel
    @FocusState private var isFocused: Bool
    
    let onSave: (TransitionModel) -> Void
    
    init(transitionService: TransitionService,category: CategoryModel, transitionPeriod: TransitionPeriod, onSave: @escaping (TransitionModel) -> Void) {
        self.onSave = onSave
        
        _viewModel = State(
            initialValue: AddTransitionViewModel(
                transitionService: transitionService,
                category: category,
                transitionPeriod: transitionPeriod
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        HStack {
                            TextField(
                                viewModel.category.categoryName,
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
                        .padding(.leading, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Color.container)
                        )
                    }
                }
            }
        }
        .padding(20)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text(viewModel.category.categoryName)
            }
            ToolbarItem(placement: .topBarTrailing) {
                SubmitButton {
                    save()
                    dismiss()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .presentationDragIndicator(.hidden)
        .task {
            isFocused = true
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
            AddTransitionView(
                category: CategoryModel(
                    categoryName: "食費",
                    transitionType: TransitionType.expense,
                    colorHex: 16753920,
                    isSystem: false,
                    isTemplateUsed: false,
                    sortOrder: 0
                ),
                transitionPeriod: TransitionPeriod(type: .expense, date: Calendar.current.startOfDay(for: Date())),
                onSave: {transition in return}
            )
            .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

