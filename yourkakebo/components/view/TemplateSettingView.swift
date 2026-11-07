//
//  TemplateSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

//
//  BudgetSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct TemplateSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            TemplateSettingContentView(
                templateService:  appContainer.templateService
            )
        }
    }
}

private struct TemplateSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    private let templateService: TemplateService
    
    @State private var viewModel: TemplateSettingViewModel
    
    init(templateService: TemplateService) {
        self.templateService = templateService
        
        _viewModel = State(initialValue: TemplateSettingViewModel(templateService: templateService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack {
            TextToggle(
                items: [
                    .init(title: "支出", value: .expense),
                    .init(title: "収入", value: .income)
                ],
                selection: viewModel.transitionType,
                onSelectionChanged: { value in
                    viewModel.transitionType = value;
                }
            )
            
            List {
                ForEach(viewModel.templates) { item in
                    templateCard(item)
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
                                viewModel.templateToDelete = item
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                }
                .onMove(
                    perform: moveTemplate
                )
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.visible)
            .contentMargins(.top, 8, for: .scrollContent)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSelectCategory = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                Color(
                                    red: 0.27,
                                    green: 0.27,
                                    blue: 0.27
                                )
                            )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showSelectCategory,
               onDismiss: {
            try? viewModel.load()
        }
        ) {
            NavigationStack {
                SelectTemplateCategorySheet(transitionType: viewModel.transitionType, usedCategories: viewModel.usedCategories)
                    .presentationBackground(Color.modalSheetBackground)
                    .presentationDragIndicator(.hidden)
            }
        }
        .alert(
            "テンプレート削除",
            isPresented: Binding(
                get: {
                    viewModel.templateToDelete != nil
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
                deleteTemplate()
            }
        } message: {
            Text("※すでに記録されているこのカテゴリの収支は削除されません。")
        }
        .task(id: viewModel.transitionType) {
            try? viewModel.load()
        }
    }
    
    private func templateCard (
        _ template: TemplateModel
    ) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color(hex: template.category.colorHex))
                             .frame(width: 12, height: 12)
            Text(template.category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
    
    private func moveTemplate (
        from source: IndexSet,
        to destination: Int
    ) {
        do {
            try viewModel.moveTemplate(
                from: source,
                to: destination,
            )
        }
        catch {
            print("テンプレートの並び替えに失敗: \(error)")
        }
    }
    
    private func deleteTemplate() {
        do {
            try viewModel.deleteTemplate()
        } catch {
            print("テンプレートの削除に失敗: \(error)")
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
        NavigationStack{
            TemplateSettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
