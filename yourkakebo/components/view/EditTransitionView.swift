//
//  EditTransitionView.swift
//  yourkakebo
//

import SwiftUI

struct EditTransitionView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        
        EditTransitionContentView(
            appSettings: appContainer.appSettings,
            transitionService: appContainer.transitionService,
            templateService: appContainer.templateService
        )
    }
}

private struct EditTransitionContentView: View {
    @State private var isKeyboardVisible = false
    @State private var viewModel: EditTransitionViewModel
    
    @Namespace private var animation
    
    init(
        appSettings: AppSettings,
        transitionService: TransitionService,
        templateService: TemplateService
    ) {
        _viewModel = State(
            initialValue: EditTransitionViewModel(
                appSettings: appSettings,
                transitionService: transitionService,
                templateService: templateService
            )
        )
    }
    
    var body: some View {
        
        let isExpense = viewModel.transitionPeriod.type == .expense
        
        let count = isExpense
        ? viewModel.expenses.count
        : viewModel.incomes.count
        
        let uncategoriezedCount = isExpense ? viewModel.uncategorizedExpenses.count : viewModel.uncategorizedIncomes.count
        
        VStack(spacing: 16) {
            
            // MARK: - Header
            
            ZStack {
                PeriodNavigationBar(
                    formattedDate: formattedDate,
                    onPrevious: {
                        viewModel.moveDate(by: -1)
                    },
                    onNext:  {
                        viewModel.moveDate(by: 1)
                    }
                )
                HStack {
                    Spacer()
                    Button {
                        viewModel.setShowSelectedCategory()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 26))
                            .foregroundStyle(.primary)
                            .frame(
                                width: 44,
                                height: 44
                            )
                    }
                    .buttonStyle(.plain)
                    .modifier(GlassEffectModifier())
                }
                .padding(.horizontal, 16)
            }
            
            
            // MARK: - Transition List
            
            
            List {
                if(count > 0) {
                    if isExpense  {
                        ForEach($viewModel.expenses) { $item in
                            if let editingData = viewModel.editingTransition,
                               editingData.id == item.id {
                                
                                TransitionEditForm(
                                    namespace: animation,
                                    editingData: editingData,
                                    amountInput: $viewModel.amountInput,
                                    editType: $viewModel.editType,
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                
                            } else {
                                TransitionCard(
                                    data: $item,
                                    onEdit: {
                                        viewModel.setEditingTransition(item)
                                    }
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        viewModel.transitionDataToDelete = item
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }else  {
                        ForEach($viewModel.incomes) { $item in
                            if let editingData = viewModel.editingTransition,
                               editingData.id == item.id {
                                
                                TransitionEditForm(
                                    namespace: animation,
                                    editingData: editingData,
                                    amountInput: $viewModel.amountInput,
                                    editType: $viewModel.editType,
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                
                            } else {
                                TransitionCard(
                                    data: $item,
                                    onEdit: {
                                        viewModel.setEditingTransition(item)
                                    }
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        viewModel.transitionDataToDelete = item
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                    
                    if uncategoriezedCount > 0 {
                        if isExpense {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("カテゴリ未割り当て")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.leading, 8)
                                Divider()
                            }
                            .padding(.horizontal, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            ForEach($viewModel.uncategorizedExpenses) { $item in
                                UncategorizedTransitionCard(
                                    data: $item,
                                    onEdit: {
                                        viewModel.assigningTransitionData = item
                                        viewModel.showAssignTransition = true
                                    }
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        viewModel.uncategorizedTransitionDataToDelete = item
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                if item.id != viewModel.uncategorizedExpenses.last?.id {
                                    Divider()
                                        .padding(.horizontal, 8)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("カテゴリ未割り当て")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.leading, 8)
                                Divider()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            ForEach($viewModel.uncategorizedIncomes) { $item in
                                UncategorizedTransitionCard(
                                    data: $item,
                                    onEdit: {
                                        viewModel.assigningTransitionData = item
                                        viewModel.showAssignTransition = true
                                    }
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        viewModel.uncategorizedTransitionDataToDelete = item
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                if item.id != viewModel.uncategorizedIncomes.last?.id {
                                    Divider()
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                    }
                }
            }
            .contentMargins(.all, 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .scrollIndicators(.visible)
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 0)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            if viewModel.editingTransition != nil {
                ToolbarItem(placement: .topBarLeading) {
                    CancelButton(action:  {
                        viewModel.editingTransition = nil
                    }, tint: .secondaryCancelColor)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.editingTransition != nil {
                    SubmitButton {
                        save()
                        viewModel.editingTransition = nil
                    }
                } else {
                    NavigationLink {
                        SettingView()
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 19))
                    }
                    .buttonStyle(.plain)
                }
            }
            ToolbarItem(placement: .principal) {
                TextToggle(
                    items: [
                        .init(title: "支出", value: .expense),
                        .init(title: "収入", value: .income)
                    ],
                    selection: viewModel.transitionPeriod.type,
                    onSelectionChanged: { value in
                        viewModel.setTransitionPeriodType(value)
                    }
                )
            }
        }
        .alert("収支削除",
               isPresented: Binding(
                get: {
                    viewModel.transitionDataToDelete != nil
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
                try? viewModel.deleteTransition()
            }
        } message: {
            Text(
                "未入力に戻しますか？"
            )
        }
        .alert("収支削除",
               isPresented: Binding(
                get: {
                    viewModel.uncategorizedTransitionDataToDelete != nil
                },
                set: {
                    if !$0 {
                        viewModel.cancelUncategorizedDelete()
                    }
                }
               )
        ) {
            Button("キャンセル", role: .cancel) {
                viewModel.cancelUncategorizedDelete()
            }
            Button("削除", role: .destructive) {
                try? viewModel.deleteUncategorizedTransition()
            }
        } message: {
            Text(
                "未入力に戻しますか？"
            )
        }
        .sheet(isPresented: $viewModel.showSelectCategory) {
            NavigationStack {
                SelectTransitionCategorySheet(usedExpenseIds: viewModel.expenseIds, usedIncomeIds: viewModel.incomeIds, transitionPeriod: viewModel.transitionPeriod) { updatedTransition in
                    viewModel.addToData(updatedTransition)
                }
            }
            .presentationBackground(Color.modalSheetBackground)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showAssignTransition) {
            NavigationStack {
                AssignTransitionCategorySheet(transitionType: viewModel.assigningTransitionData!.transition.transitionType) { category in
                    try? viewModel.assignCategory(category)
                }
            }
        }
        .task(id: viewModel.transitionPeriod) {
            do {
                try viewModel.load(transitionPeriod: viewModel.transitionPeriod)
            } catch {
                print("Transitionの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private func save() {
        do {
            let savedTransition = try viewModel.save()
            viewModel.refreash(savedTransition)
        } catch {
            //viewModel.toast = .error(error.localizedDescription)
            print("収支の保存に失敗しました: \(error)")
        }
    }
    
    // MARK: - Computed
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M / d"
        
        return formatter.string(
            from: viewModel.transitionPeriod.date
        )
    }
    
    struct TransitionCard: View {
        @Binding var data: TransitionInputData
        
        let onEdit: () -> Void
        
        init(
            data: Binding<TransitionInputData>,
            onEdit: @escaping () -> Void,
        ) {
            self._data = data
            self.onEdit = onEdit
        }
        
        var body: some View {
            
            Button {
                onEdit()
            }
            label: {
                HStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: data.category.colorHex))
                            .frame(width: 12, height: 12)
                        Text(data.category.categoryName)
                            .font(.system(size: 18))
                            .frame(
                                width: 92,
                                alignment: .leading
                            )
                    }
                    Spacer()
                    Text("\(data.transition?.amount.formatted() ?? "0")円")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .zIndex(0)
        }
    }
    
    struct TransitionEditForm: View {
        var namespace: Namespace.ID
        let editingData: TransitionInputData
        
        @Binding var amountInput: String?
        @Binding var editType: EditTransitionType
        
        @FocusState private var isFocused: Bool
        
        var body: some View {
            
            //let placeholder = editingData.transition != nil && editType == .add ? "加算額" : "金額"
            VStack(spacing: 6) {
                HStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: editingData.category.colorHex))
                            .frame(width: 12, height: 12)
                        Text(editingData.category.categoryName)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(
                                width: 92,
                                alignment: .leading
                            )
                    }
                    Spacer()
                    if(editingData.transition != nil) {
                        Picker(
                            "種類",
                            selection: $editType
                        ) {
                            Text(EditTransitionType.add.displayString)
                                .tag(EditTransitionType.add)
                            
                            Text(EditTransitionType.overwrite.displayString)
                                .tag(EditTransitionType.overwrite)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                        .onChange(of: editType) { oldValue, newValue in
                            handleEditTypeChanged(newValue)
                        }
                    }
                }
                HStack {
                    TextField("",
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
                    .frame(height: 52)
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
                if(editingData.transition != nil && editType == .add) {
                    HStack {
                        Text("加算後の金額")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        
                        Text("\((editingData.transition!.amount + (Int(amountInput ?? "") ?? 0)).formatted())円")                                .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.container)
                    .matchedGeometryEffect(
                        id: editingData.id,
                        in: namespace
                    )
            }
            .shadow(
                color: Color.black.opacity(0.10),
                radius: 8,
                x: 0,
                y: 4
            )
            .transition(
                .opacity.combined(
                    with: .scale(scale: 0.97, anchor: .top)
                )
            )
            .zIndex(1)
            .padding(.horizontal, 8)
            .task {
                isFocused = true
            }
        }
        
        private func handleEditTypeChanged(_ type: EditTransitionType) {
            switch type {
            case .add:
                amountInput = nil
                break
            case .overwrite:
                amountInput = String(editingData.transition?.amount ?? 0)
                break
            }
        }
    }
    
    struct UncategorizedTransitionCard: View {
        @Binding var data: UncategoriezedTransitionInputData
        
        let onEdit: () -> Void
        
        init(data: Binding<UncategoriezedTransitionInputData>, onEdit: @escaping () -> Void) {
            self._data = data
            self.onEdit = onEdit
        }
        
        var body: some View {
            Button {
                onEdit()
            } label: {
                HStack(spacing: 0) {
                    Text("\(data.transition.createdAt.formatted(date: .omitted,time: .shortened))")
                    Spacer()
                    Text("\(data.transition.amount.formatted())円")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
            EditTransitionView()
        }
        .preferredColorScheme(.light)
        .modelContainer(container)
        .environment(appContainer)
    }
}
