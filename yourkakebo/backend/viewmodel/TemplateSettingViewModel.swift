//
//  FixedTransitionViewModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class TemplateSettingViewModel {
    private let templateService: TemplateService
    
    var templateToDelete: TemplateModel?
        
    init (templateService: TemplateService) {
        self.templateService = templateService
    }
    
    func selectDeleteForDeletion(
        _ template: TemplateModel
    ) {
        templateToDelete = template
    }
    
    func moveTemplate(from source: IndexSet, to destination: Int, templates: [TemplateModel]) throws {
        var reordered = templates
        
        reordered.move( fromOffsets: source,
                        toOffset: destination)
        
        for(index, template) in reordered.enumerated() {
            template.sortOrder = index
        }
        
        try templateService.save()
    }
    
    func deleteTemplate() throws {
        guard let template = templateToDelete else {
            return
        }
        
        try templateService.deleteTemplate(template)
        
        templateToDelete = nil
    }
    
    func cancelDelete() {
    templateToDelete = nil
    }
}
