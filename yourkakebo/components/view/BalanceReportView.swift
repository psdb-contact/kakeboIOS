import SwiftUI
import Charts

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
            if let data = viewModel.data {
                
                let transitionList = viewModel.trantitionType == .expense ? data.aggregatedDailyExpenses : data.aggregatedDailyIncomes
                let fixedTransitionList = viewModel.trantitionType == .expense ? data.aggregatedFixedExpenses : data.aggregatedFixedIncomes
                
                /*
                 let total = transitionList.reduce(0) { $0 + $1.amount } + fixedTransitionList.reduce(0) { $0 + $1.amount }
                 let gapAngle: Double = 4
                 let gapAmount = Int(Double(total) * gapAngle / (360 - gapAngle))
                 
                 let gap = CategoryBalanceReportDataModel(category: nil, amount: gapAmount, isFixedTransition: false, isGap: true)
                 */
                
                let chartList = transitionList +  fixedTransitionList
                
                let domain = chartList.map {
                    $0.category?.categoryName ?? "未選択"
                }
                
                let range = chartList.map {
                    Color(hex: $0.category?.colorHex ?? 0xFFBBBBBB)
                }
                
                
                VStack(spacing: 8) {
                    BalanceReportRow(
                        title: "収支",
                        amount: data.totalBalance
                    )
                    Divider()
                    HStack(spacing: 32) {
                        HStack {
                            Text("支出")
                            Spacer()
                            Text("\(data.totalExpense)")
                        }
                        HStack {
                            Text("収入")
                            Spacer()
                            Text("\(data.totalIncome)")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                transitionTypeSegmentedButton(selection: $viewModel.trantitionType)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        Chart(chartList) { item in
                            SectorMark(
                                angle: .value("金額", item.amount),
                            )
                            .foregroundStyle(
                                
                                Color(hex: item.category?.colorHex ?? 0xFFBBBBBB)
                            )
                        }
                        .chartLegend(.hidden)
                        .chartForegroundStyleScale(
                            domain: domain,
                            range: range
                        )
                        .frame(height: 200)
                        
                        /*
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
                         */
                        
                        
                        VStack(spacing: 32) {
                            BalanceReportCategoryList(
                                title: "日次",
                                data: transitionList
                            )
                            
                            BalanceReportCategoryList(
                                title: "固定",
                                data: fixedTransitionList
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
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
                        .font(.system(size: 19))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private struct transitionTypeSegmentedButton: View {
        @Binding var selection: TransitionType
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(TransitionType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = type
                            }
                        } label: {
                            Text(type.displayString)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundStyle(
                                    selection == type
                                    ? .primary
                                    : .secondary
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.primary)
                        .frame(
                            width: geometry.size.width / CGFloat(TransitionType.allCases.count),
                            height: 2
                        )
                        .offset(
                            x: geometry.size.width
                            / CGFloat(TransitionType.allCases.count)
                            * CGFloat(
                                TransitionType.allCases.firstIndex(of: selection) ?? 0
                            )
                        )
                }
                .frame(height: 2)
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
    
    private struct BalanceReportCategoryList: View {
        
        let title: String
        let data: [CategoryBalanceReportDataModel]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 8)
                Divider()
                VStack(spacing: 16) {
                    ForEach(data) { item in
                        HStack {
                            Circle()
                                .fill(Color(hex: item.category != nil ? item.category!.colorHex : 0xFFBBBBBB))
                                .frame(width: 12, height: 12)
                            Text(
                                item.category?.categoryName
                                ?? "未分類"
                            )
                            Spacer()
                            Text(item.amount.formatted(.number))
                        }
                    }
                }
                .padding(.top, 12)
            }
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

