//
//  EditTransitionSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/17.
//

import SwiftUI

struct EditTransitionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: EditTransitionSheetViewModel
    @FocusState private var isFocused: Bool
    
    let onSave: (TransitionModel) -> Void
    
    init(transitionService: TransitionService,transition:TransitionModel?,category: CategoryModel, transitionPeriod: TransitionPeriod, onSave: @escaping (TransitionModel) -> Void) {
        self.onSave = onSave
        
        _viewModel = State(
            initialValue: EditTransitionSheetViewModel(
                transitionService: transitionService,
                transition: transition,
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
                    Picker(
                        "種類",
                        selection: $viewModel.editType
                    ) {
                        Text(EditTransitionType.add.displayString)
                            .tag(EditTransitionType.add)
                        
                        Text(EditTransitionType.overwrite.displayString)
                            .tag(EditTransitionType.overwrite)
                    }
                    .pickerStyle(.segmented)
                    
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
                        HStack {
                            Text("現在の金額")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            Text("\(viewModel.transition?.amount.formatted() ?? "0")円")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .font(.system(size: 14))
                    }
                }
            }
        }
        .padding(20)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                CancelButton(action:  {dismiss() }, tint: .secondaryCancelColor)
            }
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
            EditTransitionSheet(
                transitionService: appContainer.transitionService,
                transition: nil,
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

