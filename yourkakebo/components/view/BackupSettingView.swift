//
//  BackupSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/29.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        BackupSettingContentView(
            appSettings: appContainer.appSettings,
            backupService: appContainer.backupService
        )
    }
}

private struct BackupSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let appSettings: AppSettings
    
    @State private var viewModel: BackupSettingViewModel
    
    init(appSettings: AppSettings, backupService: BackupService) {
        self.appSettings = appSettings
        
        _viewModel = State(initialValue: BackupSettingViewModel(appSettings: appSettings, backupService: backupService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("家計簿のデータをCSVファイルとして保存できます。")
                    Text("別の端末へのデータ移行や、データの保管に利用できます。")
                }
                Button {
                    viewModel.exportExternalBackup()
                } label: {
                    HStack {
                        Text("CSVファイルに書き出す")
                                    
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .ListRowComponentStyle()
                 .ListRowStyle()
                
                Button {
                    viewModel.isShowingImporter = true
                } label: {
                    HStack {
                        Text("CSVファイルから復元")
                                                
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .ListRowComponentStyle()
                 .ListRowStyle()
            } header: {
                Text("外部バックアップ")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("家計簿のデータをアプリ内に保存できます。")
                    Text("バックアップは最新の1件のみ保持され、作成するたびに上書きされます。")
                }
                Button {
                    viewModel.exportInternalBackup()
                } label: {
                    HStack {
                        Text("バックアップを作成")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .ListRowComponentStyle()
                     .ListRowStyle()
                }
                Button {
                    viewModel.importInternalBackup()
                } label: {
                    HStack {
                        Text("バックアップを復元")
                        
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .ListRowComponentStyle()
                     .ListRowStyle()
                }
            } header: {
                Text("内部バックアップ")
            }
            footer: {
                if let date = viewModel.appSettings.backupDate {
                    Text("最終バックアップ：\(date.formatted(date: .numeric, time: .shortened))")
                } else {
                    Text("バックアップはまだ作成されていません。")
                }
            }            
        }
        .ListStyle()
        
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
            BackupSettingView()
                .background(Color(uiColor: .systemGroupedBackground))
        }
        .modelContainer(container)
        .environment(appContainer)
    }
}

