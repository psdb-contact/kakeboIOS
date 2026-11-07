import SwiftUI
import SwiftData

struct FixedTransitionListScreen: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        FixedTransitionListContentScreen(
            fixedTransitionService: appContainer.fixedTransitionService,
            categoryService: appContainer.categoryService
        )
    }
}

struct FixedTransitionListContentScreen: View {
    private let fixedTransitionService: FixedTransitionService
    private let categoryService: CategoryService
    
    @State private var viewModel: FixedTransitionListViewModel
    
    
    init(
        fixedTransitionService: FixedTransitionService, categoryService: CategoryService) {
            self.fixedTransitionService = fixedTransitionService
            self.categoryService = categoryService
            
            _viewModel = State(
                initialValue: FixedTransitionListViewModel(fixedTransitionService: fixedTransitionService)
            )
        }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        List {
            ForEach(viewModel.fixedTransitionData) {item in
                fixedTransitionCard(item.fixedTransition)
                    .listRowInsets(
                        EdgeInsets(
                            top: 20,
                            leading: 0,
                            bottom: 20,
                            trailing: 0
                        )
                    )
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        12
                    }
                    .alignmentGuide(.listRowSeparatorTrailing) { dimensions in
                        dimensions.width - 12
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            viewModel.selectFixedTransitionForDeletion(item.fixedTransition)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .scrollIndicators(.visible)
        .contentMargins(.top, 8, for: .scrollContent)
        .task {
            do{
                try viewModel.load()
            }catch {
                print("Fixed Transitionの読み込みに失敗しました: \(error)")
            }
        }
        .sheet(item: $viewModel.fixedTransitionToEdit) { fixedTransition in
            NavigationStack {
                EditFixedTransitionSheet(
                    fixedTransition: fixedTransition,
                    fixedTransitionService:  fixedTransitionService,
                    categoryService: categoryService,
                )
                .presentationBackground(Color.modalSheetBackground)
                .presentationDragIndicator(.hidden)
                
            }
            
        }
        .alert(
            "固定収支削除",
            isPresented: Binding(
                get: {
                    viewModel.fixedTransitionToDelete != nil
                },
                set: {
                    if !$0 {
                        viewModel.cancelDelete()
                    }
                }
            )
        ) {
            Button("キャンセル", role: .cancel) {
                viewModel.cancelDelete()
            }
            
            Button("削除", role: .destructive) {
                deleteFixedTransition()
            }
        } message: {
            Text(
                "このカテゴリを使用している遊戯履歴のカテゴリが「その他」になります。"
            )
        }
    }
    
    private func deleteFixedTransition() {
        do {
            try viewModel.deleteFixedTransition()
        } catch {
            print("固定出費の削除に失敗: \(error)")
        }
    }
    
    private func fixedTransitionCard (_ fixedTransition: FixedTransitionModel) -> some View{
        
        Button {
            viewModel.fixedTransitionToEdit = fixedTransition
        } label: {
            VStack {
                HStack {
                    Text(fixedTransition.fixedTransitionName)
                        .font(.system(size: 17))
                        .lineLimit(1)
                    
                    Spacer()
                    Text("\(fixedTransition.amount)")
                }
                HStack {
                    Text("\(fixedTransition.category?.categoryName ?? "未選択")")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: fixedTransition.category?.colorHex ?? 0xFF888888), in: Capsule())
                    Text("\(fixedTransition.cycleDisplayString)")
                        .font(.system(size: 14))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.1), in: Capsule())
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
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
            FixedTransitionListScreen()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

