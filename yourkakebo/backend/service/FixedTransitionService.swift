import SwiftData
import Foundation

final class FixedTransitionService {
    private let modelContext: ModelContext
    private let fixedTransitionRepository: FixedTransitionRepository

    init(
        modelContext: ModelContext,
        fixedTransitionRepository: FixedTransitionRepository
    ) {
        self.modelContext = modelContext
        self.fixedTransitionRepository = fixedTransitionRepository
    }

    func getAllFixedTransitions() throws -> [FixedTransitionModel] {
        try fixedTransitionRepository.getAllFixedTransitions()
    }

    func addFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        try modelContext.transaction {
            try fixedTransitionRepository.insertFixedTransition(fixedTransition)
        }
    }

    func updateFixedTransition(_ fixedTransition: FixedTransitionModel) throws {
        try modelContext.transaction {
            try fixedTransitionRepository.updateFixedTransition(fixedTransition)
        }
    }

    func deleteFixedTransition(_ id: UUID) throws {
        try fixedTransitionRepository.deleteFixedTransition(id)
    }
}
