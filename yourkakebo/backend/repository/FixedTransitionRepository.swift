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

    func insertFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        modelContext.insert(fixedTransition)
        try modelContext.save()
    }

    func updateFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        try modelContext.save()
    }

    func deleteFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        modelContext.delete(fixedTransition)
        try modelContext.save()
    }

    func deleteFixedTransition(_ id: UUID) throws {
        let descriptor = FetchDescriptor<FixedTransitionModel>(
            predicate: #Predicate { transition in
                transition.fixedTransitionId == id
            }
        )

        guard let fixedTransition = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(fixedTransition)
        try modelContext.save()
    }

    func deleteAllFixedTransitions() throws {
        let fixedTransitions = try modelContext.fetch(
            FetchDescriptor<FixedTransitionModel>()
        )

        for fixedTransition in fixedTransitions {
            modelContext.delete(fixedTransition)
        }

        try modelContext.save()
    }
}
