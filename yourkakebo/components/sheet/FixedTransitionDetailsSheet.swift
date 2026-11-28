//
//  HistoryDetailsSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import SwiftUI
import SwiftData

struct FixedTransitionDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: FixedTransitionDetailsSheetViewModel
    
    init(
        fixedTransitionService: FixedTransitionService,
        selectedDate: Date
    ) {
        _viewModel = State(
            initialValue: FixedTransitionDetailsSheetViewModel(
                fixedTransitionService: fixedTransitionService,
                selectedDate: selectedDate
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            ZStack {
                PeriodNavigationBar(
                    formattedDate: formattedDate,
                    onPrevious: {
                        viewModel.moveDate(by: -1)
                    },
                    onNext: {
                        viewModel.moveDate(by: 1)
                    }
                )
            }
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("出費")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        Divider()
                        VStack(spacing: 16) {
                            ForEach(viewModel.fixedExpenses) {item in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: item.category != nil ? item.category!.colorHex : 0xFFBBBBBB))
                                        .frame(width: 12, height: 12)
                                    Text(                                        item.fixedTransitionName)
                                    
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                        }
                        .padding(.top, 12)
                    }
                    VStack(spacing: 0){
                        HStack {
                            Text("収入")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        Divider()
                        VStack(spacing: 16) {
                            ForEach(viewModel.fixedIncomes) {item in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: item.category != nil ? item.category!.colorHex : 0xFFBBBBBB))
                                        .frame(width: 12, height: 12)
                                    Text(                                        item.fixedTransitionName)
                                    
                                    Spacer()
                                    
                                    Text(
                                        item.amount.formatted(.number)
                                    )
                                }
                            }
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CancelButton(action:  {dismiss() }, tint: .secondaryCancelColor)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.selectedDate) {
            try? viewModel.load()
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
        NavigationStack {
            HistoryDetailsSheet(
                transitionService: appContainer.transitionService,
                fixedTransitionService: appContainer.fixedTransitionService,
                selectedDate: Calendar.current.startOfDay(
                    for: Calendar.current.startOfDay(for: Date())
                )
            )
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
