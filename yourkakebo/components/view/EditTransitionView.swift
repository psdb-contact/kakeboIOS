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
                        viewModel.showSelectCategory = true
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
                LazyVStack(spacing: 12) {
                    ForEach($viewModel.transitions) { $item in
                        TransitionInputForm(
                            data: $item,
                            onFocus: {
                                viewModel.editingTransitionID = item.id
                            },
                            onBlur: {
                                item.editingAmount = item.amount
                            },
                            isSaving: viewModel.isSaving
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
            .scrollIndicators(.visible)
        }
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
            SelectCategorySheet(usedCategories: usedCategories, selectedDate: viewModel.selectedDate)
                .presentationDragIndicator(.hidden)
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
}


// MARK: - TransitionInputForm

struct TransitionInputForm: View {
    @Binding var data: TransitionInputData
    
    let onFocus: () -> Void
    let onBlur: () -> Void
    let isSaving: Bool
    
    @FocusState private var isFocused: Bool
    
    init(
        data: Binding<TransitionInputData>,
        onFocus: @escaping () -> Void,
        onBlur:@escaping () -> Void,
        isSaving: Bool
    ) {
        self._data = data
        self.onFocus = onFocus
        self.onBlur = onBlur
        self.isSaving =  isSaving
    }
    
    var body: some View {
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
            .font(.system(size: 18))
            .foregroundStyle(
                Color(
                    red: 0.267,
                    green: 0.267,
                    blue: 0.267
                )
            )
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
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 24)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.containerColor)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}
