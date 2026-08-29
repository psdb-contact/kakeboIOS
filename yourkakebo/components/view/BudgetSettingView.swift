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
        BudgetSettingContentView(
            budgetService:  appContainer.budgetService,
            categoryService: appContainer.categoryService
        )
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
            HStack(spacing: 0) {
                
                Button {
                    viewModel.moveDate(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
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
                
                Text(formattedDate)
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color(
                            red: 0.133,
                            green: 0.133,
                            blue: 0.133
                        )
                    )
                    .frame(width: 160)
                
                Button {
                    viewModel.moveDate(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
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
            }
            List {
                ForEach(viewModel.budgetData) { budget in
                    budgetCard(data: budget, onSave: { _ in })
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
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .contentMargins(.vertical, 8, for: .scrollContent)
        }
        .task(id: viewModel.selectedDate) {
            do {
                try viewModel.load(viewModel.selectedDate)
            } catch {
                print("Budgetの読み込みに失敗しました")
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M / d"
        
        return formatter.string(
            from: viewModel.selectedDate
        )
    }
}

struct budgetCard: View {
    let data: BudgetSettingData
    let onSave: (Int) -> Void
    
    @State private var text: String
    
    init(data: BudgetSettingData,
         onSave: @escaping (Int) -> Void
) {
        self.data =  data
        self.onSave = onSave
        
        _text = State(
            initialValue: String(data.budget?.amount ?? 0 )
        )
    }
    
    var body: some View {
        HStack{
            Text(data.category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
            TextField("",
                      text: $text
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 16))
            .foregroundStyle(
                Color(
                    red: 0.267,
                    green: 0.267,
                    blue: 0.267
                )
            )
            .padding(.leading, 4)
            .frame(height: 44)
            .onChange(of: text) { _, newValue in
                text = String(
                    newValue
                        .filter { $0.isNumber }
                        .prefix(6)
                )
            }
            .onSubmit {
                save()
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
    
    private func save() {
        let value = Int(text) ?? 0
        
        onSave(value)
    }
}
