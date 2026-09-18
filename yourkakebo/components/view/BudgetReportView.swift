import SwiftUI

struct BudgetReportView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        
        BudgetReportContentView(
            transitionService: appContainer.transitionService,
            fixedTransitionService: appContainer.fixedTransitionService,
            budgetService: appContainer.budgetService
        )
    }
}

private struct BudgetReportContentView: View {
    
    @State private var viewModel: BudgetReportViewModel
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService,
        budgetService: BudgetService
    ) {
        _viewModel = State(
            initialValue: BudgetReportViewModel(
                transitionService: transitionService,
                fixedTransitionService: fixedTransitionService,
                budgetService: budgetService
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            PeriodNavigationBar(
                formattedDate: viewModel.period.type == .yearly ? formattedYear:  formattedMonth,
                onPrevious: {
                    viewModel.period.type == .yearly ? viewModel.moveYear(by: -1) : viewModel.moveMonth(by: -1)
                },
                onNext: {
                    viewModel.period.type == .yearly ? viewModel.moveYear(by: 1) : viewModel.moveMonth(by: 1)
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.data) { item in
                        BudgetCard(data:item)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 16)
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

struct BudgetCard: View {
    let data: BudgetReportDataModel
    
    private var isOver: Bool {
        data.balanceAmount > data.budgetAmount
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text(data.category != nil ? data.category!.categoryName : "全て")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    HStack {
                        Text(isOver ? "超過" : "残り")
                            .foregroundStyle(Color.primary)
                        
                        Text("\(data.budgetAmount - data.balanceAmount)円")
                            .font(.system(size: 16)).foregroundStyle(isOver ? Color.red : Color.primary)
                    }
                }
                CustomProgressBar(
                    progress: Double(data.balanceAmount) / Double(data.budgetAmount),
                    color: Color(hex: data.category?.colorHex ?? 0xFFBBBBBB)
                )
                .padding(.top, 12)
                .padding(.bottom, 6)
                
                HStack {
                    HStack {
                        Text("支出").font(AppTextStyle.caption).foregroundStyle(Color.secondary)
                        Text("\(data.balanceAmount)円").font(AppTextStyle.caption).foregroundStyle(Color.secondary)
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        HStack {
                            Text("予算").font(AppTextStyle.caption).font(AppTextStyle.caption).foregroundStyle(Color.secondary)
                            Text("\(data.budgetAmount)円").font(AppTextStyle.caption).foregroundStyle(Color.secondary)
                        }
                        Text("\(data.balanceAmount / data.budgetAmount * 100)%")
                            .frame(width: 64, alignment: .trailing)
                    }
                }
                
            }
        }
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
        BudgetReportView()
            .modelContainer(container)
            .environment(appContainer)
    }
}

