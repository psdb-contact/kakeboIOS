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
            Color.secondBackground.ignoresSafeArea()
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
        
        _viewModel = State(initialValue: TemplateSettingViewModel(
                templateService: templateService
            )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.templates) { item in
                    templateCard(item)
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 8,
                                bottom: 4,
                                trailing: 8
                            )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .onMove(
                    perform: moveTemplate
                )
            }
            .listStyle(.plain)
            .scrollIndicators(.visible)
        }
        .toolbar {
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
        .sheet(isPresented: $viewModel.showSelectCategory) {
            NavigationStack {
                SelectTemplateCategorySheet(usedCategories: viewModel.usedCategories)
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
            Text(
                "TODO"
            )
        }
        .task {
            try? viewModel.load()
        }
    }
    
    private func templateCard (
        _ template: TemplateModel
    ) -> some View {
        HStack {
            Text(template.category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 0) {
                Button {
                    viewModel.selectDeleteForDeletion(template)
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.containerColor)
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
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
