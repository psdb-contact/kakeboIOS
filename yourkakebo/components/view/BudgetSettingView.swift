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
            Color.secondBackground.ignoresSafeArea()
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
            allBudgetCard(
                data: $viewModel.allBudgetData,
                onFocus: {
                    viewModel.focusedDataId = viewModel.allBudgetData.id
                },
                onUnfocus: {
                    viewModel.focusedDataId = nil
                },
                onSetTotal: {
                    try? viewModel.setTotal()
                },
                isSaving: viewModel.isSaving
            )
            ScrollView {
                ForEach($viewModel.budgetData) { $data in
                    budgetCard(
                        data: $data,
                        onFocus: {
                            viewModel.focusedDataId = data.id
                        },
                        onUnfocus: {
                            viewModel.focusedDataId = nil
                        },
                        isSaving: viewModel.isSaving
                    )
                    if data.id != viewModel.budgetData.last?.id {
                        Divider()
                            .padding(.horizontal, 8)
                    }
                }
            }
            .scrollIndicators(.visible)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .padding(8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                CancelButton(action:  {dismiss() }, tint: .secondaryCancelColor)
            }
            ToolbarItem(placement: .principal) {
                
            }
        }
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
        .alert(
            "予算設定",
            isPresented: Binding(
                get: {
                    viewModel.editingDataId != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.editingDataId = nil
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

struct allBudgetCard: View {
    @Binding var data: BudgetSettingData
    
    let onFocus: () -> Void
    let onUnfocus: () -> Void
    let onSetTotal: () -> Void
    let isSaving: Bool
    
    @FocusState private var isFocused: Bool
    
    init(data: Binding<BudgetSettingData>,
         onFocus: @escaping () -> Void,
         onUnfocus: @escaping () -> Void,
         onSetTotal: @escaping () -> Void,
         isSaving: Bool
    ) {
        self._data =  data
        self.onFocus = onFocus
        self.onUnfocus = onUnfocus
        self.onSetTotal = onSetTotal
        self.isSaving = isSaving
    }
    
    var body: some View {
        VStack{
            VStack(spacing: 0) {
                HStack{
                    Text("全て")
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Spacer()
                    TextField("未設定",
                              text: Binding(
                                get: {
                                    data.amountInput ?? ""
                                },
                                set: { newValue in
                                    let value = String(
                                        newValue
                                            .filter { $0.isNumber }
                                            .prefix(6)
                                    )
                                    data.amountInput = value.isEmpty ? nil : value
                                }
                              )
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 18))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .focused($isFocused)
                    .onChange(of: isFocused) { _, focused in
                        if focused {
                            onFocus()
                        } else if !isSaving {
                            data.amountInput = data.budget != nil ? String(data.budget!.amount) : nil
                            onUnfocus()
                        }
                    }
                    
                }
                .padding(.top, 8)
                .padding(.leading, 16)
                .padding(.trailing, 4)
                .frame(maxWidth: .infinity)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 10,
                    x: 0,
                    y: 4
                )
                HStack {
                    Spacer()
                    Button {
                        onSetTotal()
                    } label: {
                        Text("全カテゴリの合計を設定")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.submitColor)
                    }
                    .frame(minHeight: 44)
                }
                .padding(.trailing, 8)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            }            .padding(8)
        }
    }
}

struct budgetCard: View {
    @Binding var data:  BudgetSettingData
    
    let onFocus: () -> Void
    let onUnfocus: () -> Void
    let isSaving: Bool
    
    
    @FocusState private var isFocused: Bool
    
    init(data: Binding<BudgetSettingData>,
         onFocus: @escaping () -> Void,
         onUnfocus: @escaping () -> Void,
         isSaving: Bool
    ) {
        self._data =  data
        self.onFocus = onFocus
        self.onUnfocus = onUnfocus
        self.isSaving = isSaving
    }
    
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
            TextField("未設定",
                      text: Binding(
                        get: {
                            data.amountInput.map { "\($0)円" } ?? ""
                        },
                        set: { newValue in
                            let value = String(
                                newValue
                                    .filter { $0.isNumber }
                                    .prefix(6)
                            )
                            data.amountInput = value.isEmpty ? nil : value
                        }
                      )
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 18))
            .padding(.horizontal, 12)
            .frame(height: 44)
            .focused($isFocused)
            .onChange(of: isFocused) { _, focused in
                if focused {
                    onFocus()
                } else if !isSaving {
                    data.amountInput = data.budget != nil ? String(data.budget!.amount) : nil
                    onUnfocus()
                }
            }
            
        }
        .padding(.top, 2)
        .padding(.bottom, 2)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
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
