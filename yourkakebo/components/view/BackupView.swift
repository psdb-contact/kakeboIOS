//
//  BackupSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/29.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        ZStack {
            Color.secondBackground.ignoresSafeArea()
            BackupContentView(
                appSettings: appContainer.appSettings,
                backupService: appContainer.backupService
            )
        }
    }
}

private struct BackupContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appSettings: AppSettings
    
    @State private var viewModel: BackupViewModel
    
    init(appSettings: AppSettings, backupService: BackupService) {
        self.appSettings = appSettings
        
        _viewModel = State(initialValue: BackupViewModel(appSettings: appSettings, backupService: backupService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ScrollView {
            VStack(spacing: 12) {
                VStack {
                    Button {
                        viewModel.exportExternalBackup()
                    } label: {
                        HStack {
                            Text("外部バックアップ作成")
                            
                            Spacer()
                            
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    Button {
                        viewModel.isShowingImporter = true
                    } label: {
                        HStack {
                            Text("外部バックアップ復元")
                            
                            Spacer()
                            
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
                
                VStack {
                    Text(viewModel.appSettings.backupDate?.ISO8601Format() ?? "")
                    Button {
                        viewModel.exportInternalBackup()
                    } label: {
                        HStack {
                            Text("内部バックアップ作成")
                            
                            Spacer()
                            
                            
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    Button {
                        viewModel.importInternalBackup()
                    } label: {
                        HStack {
                            Text("内部バックアップ復元")
                            
                            Spacer()
                            
                            
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .fileExporter(
            isPresented: $viewModel.isShowingExporter,
            document: viewModel.exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "\(Calendar.current.startOfDay(for: Date()))kekebo"
        ) { result in
            switch result {
            case .success(let url):
                viewModel.toast = .success("バックアップ保存成功: \(url)")
                
            case .failure(let error):
                viewModel.toast = .error( "バックアップ保存失敗: \(error)")
            }
        }
        .fileImporter(
            isPresented: $viewModel.isShowingImporter,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                try? viewModel.importExternalBackup(from: url)
                
            case .failure(let error):
                print(error)
            }
        }
        .toast(toast: $viewModel.toast)
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
        NavigationStack {
            BackupView()
                .background(Color.modalSheetBackground)
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

