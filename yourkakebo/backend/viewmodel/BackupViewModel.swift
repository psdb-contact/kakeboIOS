//
//  BackupViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/09/29.
//

import Observation
import Foundation

@Observable
final class BackupViewModel {
    let appSettings: AppSettings
    private let backupService: BackupService
    
    var exportDocument: CSVDocument?
    var isShowingExporter = false
    var isShowingImporter = false
    
    var errorMessage: String?
    var isShowingError = false
    
    var toast: ToastData?
    
    init(appSettings: AppSettings, backupService: BackupService) {
        self.appSettings = appSettings
        self.backupService = backupService
    }
    
    func exportExternalBackup() {
        do {
            let data = try backupService.exportExternalBackup()
            
            exportDocument = CSVDocument(data: data)
            isShowingExporter = true
        } catch {
            showError(error)
        }
    }
    
    func importExternalBackup(from url: URL) throws{
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw CocoaError(.fileReadNoPermission)
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            let data = try Data(contentsOf: url)
            
            try backupService.importExternalBackup(data)
        } catch {
            showError(error)
        }
    }
    
    func exportInternalBackup() {
        do {
            try backupService.exportInternalBackup()
            appSettings.backupDate = Date()
            toast = .success("バックアップを作成しました。")
        } catch {
            toast = .error("バックアップの作成に失敗しました。")
        }
    }
    
    func importInternalBackup() {
        do {
            try backupService.importInternalBackup()
            toast = .success("バックアップを復元しました。")
        } catch {
            toast = .error("バックアップの復元に失敗しました。")
        }
    }
    
    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
        isShowingError = true
    }
}
