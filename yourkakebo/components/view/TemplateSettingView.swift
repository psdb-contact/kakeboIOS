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
        TemplateSettingContentView(
            templateService:  appContainer.templateService
        )
    }
}

private struct TemplateSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    private let templateService: TemplateService
    
    @Query(sort: \TemplateModel.sortOrder)
    private var templates: [TemplateModel]
    
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
                ForEach(templates) { item in
                    templateCard(item)
                        .listRowInsets(
                            EdgeInsets(
                                top: 4,
                                leading: 8,
                                bottom: 4,
                                trailing: 8
                            )
                        )
                        .listRowSeparator(.hidden)
                }
                .onMove(
                    perform: moveTemplate
                )
            }
            .listStyle(.plain)
            .scrollIndicators(.visible)
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
    }
    
    private func templateCard (
        _ template: TemplateModel
    ) -> some View {
        HStack {
            Text(template.category.categoryName)
                .font(.system(size: 17))
                .lineLimit(1)

            Spacer()

            HStack(spacing: 16) {

                Button {
                    viewModel.selectDeleteForDeletion(template)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                        .frame(width: 44, height: 44)
                }

                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        Color(
                            red: 0.33,
                            green: 0.33,
                            blue: 0.33
                        )
                    )
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
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
                templates: templates
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
