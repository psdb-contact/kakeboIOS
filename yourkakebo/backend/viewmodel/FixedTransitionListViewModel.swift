//
//  FixedTransitionViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import Foundation
import Observation
import SwiftUI
import SwiftData

@Observable
final class FixedTransitionListViewModel {
    private let fixedTransitionService: FixedTransitionService
    
    var fixedTransitionData: [FixedTransitionData] = []
    
    private var saveObserver: NSObjectProtocol?
    
    
    var fixedTransitionToDelete: FixedTransitionModel?
    var fixedTransitionToEdit: FixedTransitionModel? 
    
    init (fixedTransitionService: FixedTransitionService) {
        self.fixedTransitionService = fixedTransitionService
        
        saveObserver = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            try? self?.load()
        }
    }
    
    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
        }
    }
    
    func load() throws {
        let fixedTransitions = try fixedTransitionService.getAllFixedTransitions()
        
        fixedTransitionData = fixedTransitions.map {
            fixedTransition in
            FixedTransitionData(fixedTransition: fixedTransition)
        }
    }
    
    func deleteFixedTransition() throws {
        guard let fixedTransition = fixedTransitionToDelete else {
            return
        }
        
        try fixedTransitionService.deleteFixedTransition(fixedTransition.fixedTransitionId)
        
        fixedTransitionToDelete = nil
        
        try load()
    }
    
    func selectFixedTransitionForDeletion (
        _ fixedTransition: FixedTransitionModel
    ) {
        fixedTransitionToDelete = fixedTransition
    }
    
    func cancelDelete() {
        fixedTransitionToDelete = nil
    }
}

struct FixedTransitionData: Identifiable {
    let id = UUID()
    
    let fixedTransition: FixedTransitionModel
}
