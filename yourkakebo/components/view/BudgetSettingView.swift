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
    
    @State private var isKeyboardVisible = false
    
    @FocusState private var focusedItem: BudgetSettingData?
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
                allBudgetCard(
                    data: $viewModel.allBudgetData,
                    amountInput: $viewModel.amountInput,
                    focusedItem: $focusedItem,
                    onSetTotal: {
                        try? viewModel.setTotal()
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
                ForEach($viewModel.budgetData) { $data in
                    budgetCard(
                        data: $data,
                        amountInput: $viewModel.amountInput,
                        focusedItem: $focusedItem
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
                }
            }
            .onChange(of: focusedItem) { _, newValue in
                guard let newValue else {
                    return
                }
                
                if viewModel.editingBudgetData?.id != newValue.id {
                    viewModel.editingBudgetData = newValue
                    viewModel.amountInput = newValue.budget.map {
                        String($0.amount)
                    } ?? ""
                }
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.visible)
            .contentMargins(.top, 8, for: .scrollContent)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar{
            if(focusedItem != nil) {
                ToolbarItem(placement: .topBarLeading) {
                    CancelButton(action:  {
                        focusedItem = nil
                        viewModel.editingBudgetData = nil
                    }, tint: .secondaryCancelColor)
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    PrevPageButton(
                        action:  {
                            dismiss()
                        },
                        tint: .secondaryCancelColor
                    )
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
                    viewModel.alertBudgetData != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.alertBudgetData = nil
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
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillShowNotification
            )
        ) { _ in
            isKeyboardVisible = true
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIResponder.keyboardWillHideNotification
            )
        ) { _ in
            isKeyboardVisible = false
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
        
        var focusedItem: FocusState<BudgetSettingData?>.Binding
        
        let onSetTotal: () -> Void
        
        var body: some View {
            HStack{
                Text("全て")
                    .font(.system(size: 17))
                    .lineLimit(1)
                Spacer()
                TextField("未設定",
                          text: Binding(
                            get: {
                                focusedItem.wrappedValue?.id == data.id
                                ? (amountInput ?? "")
                                : data.budget.map { String($0.amount) } ?? ""
                            },
                            set: { newValue in
                                guard focusedItem.wrappedValue?.id == data.id else {
                                    return
                                }
                                
                                amountInput = String(
                                    newValue.filter { $0.isNumber }.prefix(6)
                                )
                            }
                          )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18))
                .frame(height: 44)
                .focused(focusedItem, equals: data)
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
    
    private struct budgetCard: View {
        @Binding var data:  BudgetSettingData
        @Binding var amountInput: String?
        var focusedItem: FocusState<BudgetSettingData?>.Binding
        
        var body: some View {
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
                TextField(
                    "未設定",
                    text: Binding(
                        get: {
                            focusedItem.wrappedValue?.id == data.id
                            ? (amountInput ?? "")
                            : data.budget.map { String($0.amount) } ?? ""
                        },
                        set: { newValue in
                            guard focusedItem.wrappedValue?.id == data.id else {
                                return
                            }
                            
                            amountInput = String(
                                newValue.filter { $0.isNumber }.prefix(6)
                            )
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 18))
                .frame(height: 44)
                .focused(focusedItem, equals: data)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            
        }
        
        private struct allBudgetInputForm: View {
            var namespace: Namespace.ID
            let editingData: BudgetSettingData
            
            @Binding var amountInput: String?
            
            @FocusState private var isFocused: Bool
            
            var body: some View {
                VStack{}
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
