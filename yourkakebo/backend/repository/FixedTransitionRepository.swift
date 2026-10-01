//
//  FixedTransitionModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@MainActor
final class FixedTransitionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getAllFixedTransitions() throws -> [FixedTransitionModel] {
        let descriptor = FetchDescriptor<FixedTransitionModel>(
            sortBy: [
                SortDescriptor(\.startDate)
            ]
        )

        return try modelContext.fetch(descriptor)
    }
    
    func getAllFixedTransitionsByTransitionType(_ transitionType: TransitionType) throws -> [FixedTransitionModel] {
        let descriptor = FetchDescriptor<FixedTransitionModel>(
            sortBy: [
                SortDescriptor(\.startDate)
            ]
        )

        let fixedTransitions =  try modelContext.fetch(descriptor)
        
        return fixedTransitions.filter {
            $0.transitionType == transitionType
        }
    }
    
    func getAllFixedTransitionsByCategoryId(_ categoryId: UUID) throws -> [FixedTransitionModel] {
        let descriptor = FetchDescriptor<FixedTransitionModel> (
            predicate: #Predicate {
                $0.category?.categoryId == categoryId
            }
        )
        
        return try modelContext.fetch(descriptor)
    }

    func insertFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        modelContext.insert(fixedTransition)
        try modelContext.save()
    }

    func updateFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        try modelContext.save()
    }
    
    func setCategoryForFixedTransitions(prev: CategoryModel, next: CategoryModel?) throws {
        let fixedTransitions = try getAllFixedTransitionsByCategoryId(prev.categoryId)
        
        for fixedTransition in fixedTransitions {
            fixedTransition.category = next
        }
    }

    func deleteFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        modelContext.delete(fixedTransition)
        try modelContext.save()
    }
    
    func deleteFixedTransitionByCategory(_ category: CategoryModel) throws {
        let fixedTransitions = try getAllFixedTransitionsByCategoryId(category.categoryId)
        
        for fixedTransition in fixedTransitions {
            modelContext.delete(fixedTransition)
        }
    }

    func deleteAllFixedTransitions() throws {
        let fixedTransitions = try modelContext.fetch(
            FetchDescriptor<FixedTransitionModel>()
        )

        for fixedTransition in fixedTransitions {
            modelContext.delete(fixedTransition)
        }
    }
}
