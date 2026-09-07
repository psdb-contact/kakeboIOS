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
        
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.fixedTransitionData) {item in
                        fixedTransitionCard(item.fixedTransition)
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
        }
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
        HStack {
            Text(fixedTransition.fixedTransitionName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
            HStack(spacing: 0) {
                Button {
                    viewModel.fixedTransitionToEdit = fixedTransition
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.iconColor)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderless)

                
                Button {
                    viewModel.selectFixedTransitionForDeletion(fixedTransition)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.iconColor)
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.borderless)

            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.containerColor))
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
            FixedTransitionListScreen()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

