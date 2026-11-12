//
//  BudgetSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI

struct BudgetSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            BudgetSettingContentView(
                budgetService:  appContainer.budgetService,
                categoryService: appContainer.categoryService
            )
        }
    }
}

private struct BudgetSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    private let budgetService: BudgetService
    private let categoryService: CategoryService
    
    @Namespace private var animation
    @State private var viewModel: BudgetSettingViewModel
    
    init(budgetService: BudgetService, categoryService: CategoryService) {
        self.budgetService = budgetService
        self.categoryService = categoryService
        
        _viewModel = State(
            initialValue: BudgetSettingViewModel(
                budgetService: budgetService,
                categoryService: categoryService
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            PeriodNavigationBar(
                formattedDate: formattedMonth,
                onPrevious: {viewModel.moveMonth(by: -1)},
                onNext: { viewModel.moveMonth(by: 1)}
            )
            List {
                if let editingData = viewModel.editingBudgetData,
                   editingData.id == $viewModel.allBudgetData.id {
                    allBudgetEditForm(
                        namespace: animation,
                        data: viewModel.allBudgetData,
                        amountInput: $viewModel.amountInput,
                        onSetTotal: {
                            viewModel.setTotal()
                        }
                    )
                    .listRowInsets(
                        EdgeInsets(
                            top: 12,
                            leading: 0,
                            bottom: 12,
                            trailing: 0
                        )
                    )
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        12
                    }
                    .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                        dimensions.width - 12
                    }
                } else {
                    allBudgetCard(
                        data: $viewModel.allBudgetData,
                        amountInput: $viewModel.amountInput,
                        onEdit: {
                            viewModel.setEditingBudgetData(viewModel.allBudgetData)
                        },
                    )
                    .listRowInsets(
                        EdgeInsets(
                            top: 12,
                            leading: 0,
                            bottom: 12,
                            trailing: 0
                        )
                    )
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        12
                    }
                    .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                        dimensions.width - 12
                    }
                    .swipeActions(edge: .trailing) {
                          Button {
                              viewModel.alertDeleteBudgetData = viewModel.allBudgetData
                          } label: {
                              Image(systemName: "trash")
                          }
                      }
                }
                ForEach($viewModel.budgetData) { $data in
                    if let editingData = viewModel.editingBudgetData,
                       editingData.id == data.id {
                        budgetEditForm(namespace: animation, data: data, amountInput: $viewModel.amountInput)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 16,
                                    leading: 0,
                                    bottom: 12,
                                    trailing: 0
                                )
                            )
                            .alignmentGuide(.listRowSeparatorLeading) { _ in
                                12
                            }
                            .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                                dimensions.width - 12
                            }
                    } else {
                        budgetCard(
                            data: data,
                            onEdit: {
                                viewModel.setEditingBudgetData(data)
                            }
                        )
                        .listRowInsets(
                            EdgeInsets(
                                top: 16,
                                leading: 0,
                                bottom: 16,
                                trailing: 0
                            )
                        )
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            12
                        }
                        .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                            dimensions.width - 12
                        }
                        .swipeActions(edge: .trailing) {
                              Button {
                                  viewModel.alertDeleteBudgetData = data
                              } label: {
                                  Image(systemName: "trash")
                              }
                          }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.visible)
            .contentMargins(.top, 8, for: .scrollContent)
        }
        .navigationBarBackButtonHidden(viewModel.editingBudgetData != nil)
        .toolbar{
            if(viewModel.editingBudgetData != nil) {
                ToolbarItem(placement: .topBarLeading) {
                    CancelButton(action:  {
                        viewModel.editingBudgetData = nil
                    }, tint: .secondaryCancelColor)
                }
            }
            if(viewModel.editingBudgetData != nil) {
                ToolbarItem(placement: .topBarTrailing) {
                    SubmitButton {
                        viewModel.setAlertBudgetData()
                    }
                }
            }
        }
        /*
         .safeAreaInset(edge: .bottom, spacing: 0) {
         if isKeyboardVisible {
         CloseSaveComponentOnKeyboard(
         closeAction: {
         UIApplication.shared.sendAction(
         #selector(UIResponder.resignFirstResponder),
         to: nil,
         from: nil,
         for: nil
         )
         },
         action: {
         viewModel.isSaving = true
         viewModel.editingDataId = viewModel.focusedDataId
         UIApplication.shared.sendAction(
         #selector(UIResponder.resignFirstResponder),
         to: nil,
         from: nil,
         for: nil
         )
         DispatchQueue.main.async {
         viewModel.isSaving = false
         }
         }
         )
         }
         }
         .animation(
         .easeInOut(duration: 0.25),
         value: isKeyboardVisible
         )
         */
        .alert(
            "予算設定",
            isPresented: Binding(
                get: {
                    viewModel.alertEditingBudgetData != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.alertEditingBudgetData = nil
                    }
                }
            )
        ){
            Button("この月の予算のみ変更") {
                save(false)
            }
            Button("この月以降の予算も変更") {
                save(true)
            }
            Button("キャンセル", role: .cancel) {
                viewModel.cancel()
            }
        }
        .alert(
            "予算削除",
            isPresented: Binding(
                get: {
                    viewModel.alertDeleteBudgetData != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.alertDeleteBudgetData = nil
                    }
                }
            )
        ){
            Button("この月の予算のみ変更") {
                delete(false)
            }
            Button("この月以降の予算も変更") {
                delete(true)
            }
            Button("キャンセル", role: .cancel) {
                viewModel.cancel()
            }
        }
        .task(id: viewModel.selectedMonth) {
            do {
                try viewModel.load(viewModel.selectedMonth)
            } catch {
                print("Budgetの読み込みに失敗しました")
            }
        }
    }
    
    private struct allBudgetCard: View {
        @Binding var data: BudgetSettingData
        @Binding var amountInput: String?
        
        let onEdit: () -> Void
        
        var body: some View {
            Button {
                onEdit()
            } label: {
                HStack{
                    Text("全て")
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                    
                    Text("\(data.budget?.amount.formatted() ?? "0")円")
                        .foregroundStyle(.secondary)
                    
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct allBudgetEditForm: View {
        var namespace: Namespace.ID
        let data: BudgetSettingData
        
        @Binding var amountInput: String?
        let onSetTotal: () -> Void
        
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack{
                HStack {
                    Text("全て")
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                    Button{
                        onSetTotal()
                    } label: {
                        Text("全カテゴリの合計を設定")
                    }
                }
                HStack {
                    TextField(
                        "未設定",
                        text: Binding(
                            get: {
                                amountInput ?? ""
                            },
                            set: { newValue in
                                let value = String(
                                    newValue
                                        .filter { $0.isNumber }
                                        .prefix(6)
                                )
                                amountInput = value.isEmpty ? nil : value
                            }
                        )
                    )
                    .keyboardType(.numberPad)
                    .font(.system(size: 19))
                    .frame(height: 44)
                    .focused($isFocused)
                    if(amountInput != nil) {
                        Button {
                            amountInput = nil
                        }  label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 8)
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .task {
                isFocused = true
            }
        }
    }
    
    private struct budgetCard: View {
        let data:  BudgetSettingData
        let onEdit: () -> Void
        
        var body: some View {
            Button {
                onEdit()
            } label: {
                HStack{
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: data.category!.colorHex))
                            .frame(width: 12, height: 12)
                        Text(data.category!.categoryName)
                            .font(.system(size: 17))
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(data.budget?.amount.formatted() ?? "0")円")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct budgetEditForm: View {
        var namespace: Namespace.ID
        let data: BudgetSettingData
        
        @Binding var amountInput: String?
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack{
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: data.category!.colorHex))
                        .frame(width: 12, height: 12)
                    Text(data.category!.categoryName)
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    TextField(
                        "未設定",
                        text: Binding(
                            get: {
                                amountInput ?? ""
                            },
                            set: { newValue in
                                let value = String(
                                    newValue
                                        .filter { $0.isNumber }
                                        .prefix(6)
                                )
                                amountInput = value.isEmpty ? nil : value
                            }
                        )
                    )
                    .keyboardType(.numberPad)
                    .font(.system(size: 19))
                    .frame(height: 44)
                    .focused($isFocused)
                    if(amountInput != nil) {
                        Button {
                            amountInput = nil
                        }  label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 8)
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .task {
                isFocused = true
            }
        }
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M"
        
        return formatter.string(
            from: viewModel.selectedMonth
        )
    }
    
    private func save(_ isPeriod: Bool) {
        do {
            try viewModel.save(isPeriod: isPeriod)
        } catch {
            print("Transition：\(error)")
        }
    }
    
    private func delete(_ isPeriod: Bool) {
        do {
            try viewModel.delete(isPeriod)
        } catch {
            print("Transition：\(error)")
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
            BudgetSettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
