//
//  ReportView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/16.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackground.ignoresSafeArea()
            SettingContentView()
        }
    }
}

private struct SettingContentView: View {
    
    init(
    ) {
        
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack {
                    NavigationLink {
                        TemplateSettingView()
                    } label: {
                        HStack {
                            Text("テンプレート設定").font(.system(size: 16)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 16)
                    }
                    
                    Divider().padding(.horizontal, 12)
                    NavigationLink {
                        CategorySettingView()
                    } label: {
                        HStack {
                            Text("カテゴリ設定").font(.system(size: 16)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.gray)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    Divider().padding(.horizontal, 12)

                    NavigationLink {
                        FixedTransitionSettingView()
                    } label: {
                        HStack {
                            Text("固定出費 収入").font(.system(size: 16)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.gray)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    Divider().padding(.horizontal, 12)

                    NavigationLink {
                        BudgetSettingView()
                    } label: {
                        HStack {
                            Text("予算設定").font(.system(size: 16)).foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.gray)
                        }
                        .padding(.top,  12)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 16)
                    }
                }.background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.container)
                )
            }
        }.padding(.horizontal, 16)
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
            SettingView()
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}
