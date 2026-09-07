//
//  HistoryDetailsSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import SwiftUI
import SwiftData

struct HistoryDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: HistoryDetailsSheetViewModel
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService,
        selectedDate: Date
    ) {
        _viewModel = State(
            initialValue: HistoryDetailsSheetViewModel(
                transitionService: transitionService,
                fixedTransitionService: fixedTransitionService,
                selectedDate: selectedDate
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 14) {
                        Text("出費")
                            .font(
                                .system(size: 20, weight: .bold)
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        VStack(spacing: 12) {
                            ForEach(viewModel.expenses) {item in
                                HStack {
                                    
                                    Text(
                                        item.category?.categoryName
                                        ?? "未分類"
                                    )
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                            ForEach(viewModel.fixedExpenses) {item in
                                HStack {
                                    
                                    Text(
                                        item.category?.categoryName
                                        ?? "未分類"
                                    )
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                        }
                    }
                    VStack(spacing: 14) {
                        Text("収入")
                            .font(
                                .system(size: 20, weight: .bold)
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        VStack(spacing: 12) {
                            ForEach(viewModel.incomes) {item in
                                HStack {
                                    
                                    Text(
                                        item.category?.categoryName
                                        ?? "未分類"
                                    )
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                            ForEach(viewModel.fixedIncomes) {item in
                                HStack {
                                    
                                    Text(
                                        item.category?.categoryName
                                        ?? "未分類"
                                    )
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                        }
                    }
                }
            }.padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            try? viewModel.load()
        }
    }
}

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
        HistoryDetailsSheet(
            transitionService: appContainer.transitionService,
            fixedTransitionService: appContainer.fixedTransitionService,
            selectedDate: Calendar.current.startOfDay(
                for: Date()
            )
        )
        .modelContainer(container)
        .environment(appContainer)
    }
}
