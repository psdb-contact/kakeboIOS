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
    @State private var isKeyboardVisible = false
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
                .safeAreaPadding(.horizontal)
            }
            
            // MARK: - Transition List
            
            if(!$viewModel.transitions.isEmpty) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($viewModel.transitions) { $item in
                            TransitionCard(
                                data: $item,
                                onEdit: {
                                    viewModel.editingDataId = item.id
                                    viewModel.editingTransition = item.transition
                                    viewModel.editingCategory = item.category
                                    viewModel.showEditTransition = true
                                }
                            )
                            
                            if item.id != viewModel.transitions.last?.id {
                                Divider()
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .clipped()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .padding(.horizontal, 12)
                .scrollIndicators(.visible)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, 8)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 19))
                }
                .buttonStyle(.plain)
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
        /*
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if(isKeyboardVisible) {
                CloseSaveComponentOnKeyboard(
                    closeAction: {
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
                    },
                    action: {
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
                    }
                )
            }
        }
        .animation(
                 .easeInOut(duration: 0.25),
                 value: isKeyboardVisible
             )
        .sheet(isPresented: $viewModel.showSelectCategory) {
            let usedCategories: [CategoryModel] = viewModel.transitions.map {
                $0.category
            }
            NavigationStack {
                SelectTransitionCategorySheet(usedCategories: usedCategories, transitionType: viewModel.transitionPeriod.type, selectedDate: viewModel.transitionPeriod.date)
                    .presentationDragIndicator(.hidden)
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
         */
        .sheet(isPresented: $viewModel.showEditTransition, onDismiss: {viewModel.editingDataId = nil}) {
            NavigationStack {
                EditTransitionSheet(
                    transitionService: viewModel.transitionService,
                    transition: viewModel.editingTransition,
                    category: viewModel.editingCategory!,
                    transitionPeriod: viewModel.transitionPeriod,
                ){ updatedTransition in
                    viewModel.refreash(updatedTransition)
                }
            }
            .presentationBackground(Color.modalSheetBackground)
            .presentationDragIndicator(.hidden)
        }
        .task(id: viewModel.transitionPeriod) {
            do {
                try viewModel.load(transitionPeriod: viewModel.transitionPeriod)
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
            from: viewModel.transitionPeriod.date
        )
    }
}


// MARK: - TransitionInputForm

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
        } label: {
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
            .padding(.top, 8)
            .padding(.bottom, 8)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity)
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        .preferredColorScheme(.light)
        .modelContainer(container)
        .environment(appContainer)
    }
}
