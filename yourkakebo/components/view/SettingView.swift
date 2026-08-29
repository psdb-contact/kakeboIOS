//
//  ReportView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/16.
//

import SwiftUI

struct SettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        SettingContentView(
        )
    }
}

private struct SettingContentView: View {
    
    init(
    ) {
        
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                NavigationLink {
                    TemplateSettingView()
                } label: {
                    HStack {
                        Text("テンプレート設定")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                
                
                NavigationLink {
                    CategorySettingView()
                } label: {
                    HStack {
                        Text("カテゴリ設定")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                
                NavigationLink {
                    FixedTransitionSettingView()
                } label: {
                    HStack {
                        Text("固定出費 収入")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
                NavigationLink {
                    BudgetSettingView()
                } label: {
                    HStack {
                        Text("予算設定")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                }
            }
        }
    }
}
