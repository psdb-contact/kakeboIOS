import SwiftUI

struct ReportView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        
        ReportContentView(
            transitionService: appContainer.transitionService,
            fixedTransitionService: appContainer.fixedTransitionService
        )
    }
}

private struct ReportContentView: View {
    
    @State private var viewModel: ReportViewModel
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService
    ) {
        _viewModel = State(
            initialValue: ReportViewModel(
                transitionService: transitionService,
                fixedTransitionService: fixedTransitionService
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            
            if(viewModel.reportPeriodType == .monthly) {
                MonthNavigationBar(
                    formattedDate: formattedMonth,
                    onPrevious: {
                        viewModel.moveMonth(by: -1)
                        try? viewModel.load()
                    },
                    onNext: {
                        viewModel.moveMonth(by: 1)
                        try? viewModel.load()
                    }
                )
                
            } else {
                YearNavigationBar(
                    formattedDate: formattedYear,
                    onPrevious: {
                        viewModel.moveYear(by: -1)
                        try? viewModel.load()
                    },
                    onNext: {
                        viewModel.moveYear(by: 1)
                        try? viewModel.load()
                    }
                )
            }
            
            if let data = viewModel.data {
                ReportSummaryView(data: data)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    toggleButton(
                        icon: "list.bullet",
                        value: .monthly
                    )
                    
                    toggleButton(
                        icon: "calendar",
                        value: .yearly
                    )
                }
                .padding(4)
                .modifier(GlassEffectModifier())

            }
            ToolbarItem(placement: .topBarTrailing) {
                
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                }
            }
        }
        .task {
            try? viewModel.load()
        }
    }
    
    private var formattedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        return formatter.string(
            from: viewModel.selectedDate
        )
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / M"
        
        return formatter.string(
            from: viewModel.selectedDate
        )
    }
    
    private func toggleButton(
        icon: String,
        value: ReportPeriodType
    ) -> some View {
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.setReportPeriodType(value: value)
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .frame(
                    width: 36,
                    height: 32
                )
                .foregroundStyle(
                    viewModel.reportPeriodType == value
                        ? .primary
                        : .secondary
                )
                .background {
                    if viewModel.reportPeriodType == value {
                        Capsule()
                            .fill(.white.opacity(0.8))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Summary

private struct ReportSummaryView: View {
    
    let data: ReportDataModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                ReportCard {
                    
                    ReportRow(
                        title: "収入",
                        amount: data.totalIncome
                    )
                    
                    ReportRow(
                        title: "支出",
                        amount: data.totalExpense
                    )
                    
                    Divider()
                    
                    ReportRow(
                        title: "収支",
                        amount: data.totalBalance
                    )
                }
                
                ReportCard {
                    
                    ReportRow(
                        title: "通常収入",
                        amount: data.totalDailyIncome
                    )
                    
                    ReportRow(
                        title: "固定収入",
                        amount: data.totalFixedIncome
                    )
                    
                    Divider()
                    
                    ReportRow(
                        title: "通常支出",
                        amount: data.totalDailyExpense
                    )
                    
                    ReportRow(
                        title: "固定支出",
                        amount: data.totalFixedExpense
                    )
                }
                
                ReportCategoryCard(
                    title: "支出",
                    data: data.aggregatedDailyExpenses
                )
                
                ReportCategoryCard(
                    title: "固定支出",
                    data: data.aggregatedFixedExpenses
                )
                
                ReportCategoryCard(
                    title: "収入",
                    data: data.aggregatedDailyIncomes
                )
                
                ReportCategoryCard(
                    title: "固定収入",
                    data: data.aggregatedFixedIncomes
                )
            }
            .padding()
        }
    }
}


// MARK: - Row

private struct ReportRow: View {
    
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


// MARK: - Card

private struct ReportCard<Content: View>: View {
    
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


// MARK: - Category

private struct ReportCategoryCard: View {
    
    let title: String
    let data: [CategoryReportDataModel]
    
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
