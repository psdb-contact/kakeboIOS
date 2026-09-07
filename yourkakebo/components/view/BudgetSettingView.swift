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
    
    
    @State private var viewModel: BudgetSettingViewModel
    
    init(budgetService: BudgetService, categoryService: CategoryService) {
        self.budgetService = budgetService
        self.categoryService = categoryService
        
        _viewModel = State(initialValue: BudgetSettingViewModel(
            budgetService: budgetService,
            categoryService: categoryService
        )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            MonthNavigationBar(
                formattedDate: formattedMonth,
                onPrevious: {viewModel.moveMonth(by: -1)},
                onNext: { viewModel.moveMonth(by: 1)}
            )
            List {
                ForEach($viewModel.budgetData) { $data in
                    budgetCard(data: $data,  onFocus: {
                        viewModel.editingBudgetID = data.id
                    },
                               onBlur: {
                        data.editingAmount = data.amount
                    },
                               isSaving: viewModel.isSaving)
                    .listRowInsets(
                        EdgeInsets(
                            top: 4,
                            leading: 8,
                            bottom: 4,
                            trailing: 8
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.visible)
        }
        .toolbar {
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
                    save()
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
    
    private func save() {
        do {
            try viewModel.save(isPeriod: false)
        } catch {
            print("Transition：\(error)")
        }
    }
}

struct budgetCard: View {
    @Binding var data:  BudgetSettingData
    
    let onFocus: () -> Void
    let onBlur: () -> Void
    let isSaving: Bool
    
    @FocusState private var isFocused: Bool
    
    init(data: Binding<BudgetSettingData>,
         onFocus: @escaping () -> Void,
         onBlur: @escaping () -> Void,
         isSaving: Bool
    ) {
        self._data =  data
        self.onFocus = onFocus
        self.onBlur = onBlur
        self.isSaving = isSaving
    }
    
    var body: some View {
        HStack{
            Text(data.category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
            TextField("",
                      text: Binding(
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
            .padding(.horizontal, 12)
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
            
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
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
