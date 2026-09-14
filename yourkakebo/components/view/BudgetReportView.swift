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
                                               .padding(.horizontal, 12)
                            }
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
                /*
                 IconToggle(
                 items: [
                 .init(icon: "list.bullet", value: .monthly),
                 .init(icon: "calendar", value: .yearly)
                 ],
                 selection: viewModel.period.type,
                 onSelectionChanged: { value in
                 viewModel.setReportPeriodType(value: value)
                 }
                 )
                 */
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
            
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack {
                    Text(data.category != nil ? data.category!.categoryName : "全て")
                    Spacer()
                    Text("\(data.budgetAmount - data.balanceAmount)")
                }
                ProgressView(
                    value: Double(data.balanceAmount <= data.budgetAmount ? data.balanceAmount : data.budgetAmount),
                    total: Double(data.budgetAmount),
                )
                .tint(Color(hex: data.category != nil ? data.category!.colorHex : 0xFFBBBBBB))
                    
                HStack {
                    Spacer()
                    HStack {
                        Text("\(data.balanceAmount)")
                        Text("/")
                        Text("\(data.budgetAmount)")
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

