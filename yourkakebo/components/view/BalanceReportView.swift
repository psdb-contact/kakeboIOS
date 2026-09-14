import SwiftUI

struct BalanceReportView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        
        BalanceReportContentView(
            transitionService: appContainer.transitionService,
            fixedTransitionService: appContainer.fixedTransitionService
        )
    }
}

private struct BalanceReportContentView: View {
    
    @State private var viewModel: BalanceReportViewModel
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService
    ) {
        _viewModel = State(
            initialValue: BalanceReportViewModel(
                transitionService: transitionService,
                fixedTransitionService: fixedTransitionService
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            PeriodNavigationBar(
                formattedDate: viewModel.period.type == .yearly ? formattedYear : formattedMonth,
                onPrevious: {
                    viewModel.period.type == .yearly ? viewModel.moveYear(by: -1) : viewModel.moveMonth(by: -1)
                },
                onNext: {
                    viewModel.period.type == .yearly ? viewModel.moveYear(by: 1) : viewModel.moveMonth(by: 1)
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        
                        if let data = viewModel.data {
                            BalanceReportCard {
                                BalanceReportRow(
                                    title: "収入",
                                    amount: data.totalIncome
                                )
                                
                                BalanceReportRow(
                                    title: "支出",
                                    amount: data.totalExpense
                                )
                                
                                Divider()
                                
                                BalanceReportRow(
                                    title: "収支",
                                    amount: data.totalBalance
                                )
                            }
                            
                            BalanceReportCard {
                                
                                BalanceReportRow(
                                    title: "通常収入",
                                    amount: data.totalDailyIncome
                                )
                                
                                BalanceReportRow(
                                    title: "固定収入",
                                    amount: data.totalFixedIncome
                                )
                                
                                Divider()
                                
                                BalanceReportRow(
                                    title: "通常支出",
                                    amount: data.totalDailyExpense
                                )
                                
                                BalanceReportRow(
                                    title: "固定支出",
                                    amount: data.totalFixedExpense
                                )
                            }
                            
                            BalanceReportCategoryCard(
                                title: "支出",
                                data: data.aggregatedDailyExpenses
                            )
                            
                            BalanceReportCategoryCard(
                                title: "固定支出",
                                data: data.aggregatedFixedExpenses
                            )
                            
                            BalanceReportCategoryCard(
                                title: "収入",
                                data: data.aggregatedDailyIncomes
                            )
                            
                            BalanceReportCategoryCard(
                                title: "固定収入",
                                data: data.aggregatedFixedIncomes
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .task(id: viewModel.period) {
                    do {
                        try viewModel.load(period: viewModel.period)
                    } catch {
                        print("データの読み込みに失敗しました: \(error)")
                    }
                }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                TextToggle(
                    items: [.init(title: "月間", value: .monthly),
                            .init(title: "年間", value:.yearly)
                    ],
                    selection: viewModel.period.type,
                    onSelectionChanged: {value in viewModel.setReportPeriodType(value: value)}
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingView()
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                }
            }
        }
    }
    
    private struct BalanceReportRow: View {
        
        let title: String
        let amount: Int
        
        var body: some View {
            HStack {
                Text(title)
                
                Spacer()
                
                Text(amount.formatted(.number))
            }
        }
    }
    
    private struct BalanceReportCard<Content: View>: View {
        
        @ViewBuilder
        let content: () -> Content
        
        var body: some View {
            VStack(spacing: 12) {
                content()
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private struct BalanceReportCategoryCard: View {
        
        let title: String
        let data: [CategoryBalanceReportDataModel]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                Text(title)
                    .font(.headline)
                
                ForEach(data) { item in
                    
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
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    private var formattedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        return formatter.string(
            from: viewModel.period.date
        )
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M"
        
        return formatter.string(
            from: viewModel.period.date
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
        BalanceReportView()
            .modelContainer(container)
            .environment(appContainer)
    }
}

