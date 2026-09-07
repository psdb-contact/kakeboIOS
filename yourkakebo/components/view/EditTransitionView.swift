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
            transitionService: appContainer.transitionService,
            templateService: appContainer.templateService
        )
    }
}

private struct EditTransitionContentView: View {
    @State private var viewModel: EditTransitionViewModel
    
    init(
        transitionService: TransitionService,
        templateService: TemplateService
    ) {
        _viewModel = State(
            initialValue: EditTransitionViewModel(
                transitionService: transitionService,
                templateService: templateService
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Header
            
            ZStack {
                MonthNavigationBar(
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
                            .font(.system(size: 24))
                            .foregroundStyle(
                                Color(
                                    red: 0.267,
                                    green: 0.267,
                                    blue: 0.267
                                )
                            )
                            .frame(
                                width: 44,
                                height: 44
                            )
                    }
                    .modifier(GlassEffectModifier())
                }
            }
            
            // MARK: - Transition List
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($viewModel.transitions) { $item in
                        TransitionInputForm(
                            data: $item,
                            onFocus: {
                                viewModel.setEditingTransitionId(id:item.id)
                            },
                            onBlur: {
                                item.editingAmount = item.amount
                            },
                            onAddAmount: {
                                viewModel.setAddingAmount(for: item.id)
                            },
                            isSaving: viewModel.isSaving,
                        )
                        
                        if item.id != viewModel.transitions.last?.id {
                            Divider()
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.horizontal, 12)
            }
            .clipped()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.container)
            )
            .padding(.horizontal, 12)
            .scrollIndicators(.visible)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    if let index = viewModel.transitions.firstIndex(where: {
                        $0.isAddingAmount
                    }) {
                        viewModel.transitions[index].isAddingAmount = false
                        viewModel.transitions[index].addingAmount = nil
                    }
                    
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                } label: {
                    Image(systemName: "xmark")
                }
                
                Spacer()
                
                Button() {
                    
                    if let index = viewModel.transitions.firstIndex(where: {
                        $0.isAddingAmount
                    }) {
                        addAmount(index)
                    } else {
                        saveTransition()
                    }
                    
                    viewModel.isSaving = true
                    saveTransition()
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                    DispatchQueue.main.async {
                        viewModel.isSaving = false
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .sheet(isPresented: $viewModel.showSelectCategory) {
            let usedCategories: [CategoryModel] = viewModel.transitions.map {
                $0.category
            }
            NavigationStack {
                SelectTransitionCategorySheet(usedCategories: usedCategories, selectedDate: viewModel.selectedDate)
                    .presentationDragIndicator(.hidden)
            }
        }
        .task(id: viewModel.selectedDate) {
            do {
                try viewModel.loadTransitions()
            } catch {
                print("Transitionの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    // MARK: - Computed
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M / d"
        
        return formatter.string(
            from: viewModel.selectedDate
        )
    }
    
    // MARK: - Action
    
    private func saveTransition() {
        do {
            try viewModel.saveTransition()
        } catch {
            print("Transition：\(error)")
        }
    }
    
    private func addAmount(_ index: Int) {
        do {
            try viewModel.addAmount(at: index)
        } catch {
            print("Transition：\(error)")
        }
    }
}


// MARK: - TransitionInputForm

struct TransitionInputForm: View {
    @Binding var data: TransitionInputData
    
    let onFocus: () -> Void
    let onBlur: () -> Void
    let onAddAmount: () -> Void
    let isSaving: Bool
    
    @FocusState private var isFocused: Bool
    @FocusState private var isAddingFocused: Bool
    
    init(
        data: Binding<TransitionInputData>,
        onFocus: @escaping () -> Void,
        onBlur: @escaping () -> Void,
        onAddAmount: @escaping () -> Void,
        isSaving: Bool,
    ) {
        self._data = data
        self.onFocus = onFocus
        self.onBlur = onBlur
        self.onAddAmount = onAddAmount
        self.isSaving =  isSaving
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(data.category.categoryName)
                    .font(.system(size: 18))
                    .frame(
                        width: 92,
                        alignment: .leading
                    )
                
                TextField(
                    "",
                    text:Binding(
                        get: {
                            data.editingAmount.map(String.init) ?? ""
                        },
                        set: { newValue in
                            data.editingAmount = Int(
                                newValue
                                    .filter { $0.isNumber }
                                    .prefix(6)
                            )
                        }
                    )
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 20))
                .padding(.leading, 4)
                .frame(height: 44)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        if data.editingAmount == 0 {
                            data.editingAmount = nil
                        }
                        onFocus()
                    } else if !isSaving {
                        data.editingAmount = data.amount
                    }
                }
                /*
                 .onSubmit {
                 saveTransition()
                 }
                 */
                Button {
                    onAddAmount()
                    
                    DispatchQueue.main.async {
                        isAddingFocused = true
                    }
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.iconColor)
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 24)
                .buttonStyle(.borderless)
            }
            if(data.isAddingAmount) {
                TextField(
                    "",
                    text: Binding(
                        get: {
                            data.addingAmount.map(String.init) ?? ""
                        },
                        set: { newValue in
                            data.addingAmount = Int(
                                newValue
                                    .filter(\.isNumber)
                                    .prefix(6)
                            )
                        }
                    )
                )
                .focused($isAddingFocused)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 20))
            }
        }
        
        .padding(.top, 4)
        .padding(.bottom, 4)
        .padding(.leading, 8)
        .padding(.trailing, 0)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.containerColor)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .contentShape(Rectangle())
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
                .background(Color.secondBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
