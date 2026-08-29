import Foundation
import SwiftData

final class TransitionService {

    private let modelContext: ModelContext
    private let transitionRepository: TransitionRepository

    init(
        modelContext: ModelContext,
        transitionRepository: TransitionRepository
    ) {
        self.modelContext = modelContext
        self.transitionRepository = transitionRepository
    }

    func getAllTransitions() throws -> [TransitionModel] {
        try transitionRepository.getAllTransitions()
    }

    func getAllTransitionsByDate(
        _ date: Date
    ) throws -> [TransitionModel] {
        try transitionRepository.getAllTransitionsByDate(date)
    }

    func addTransition(
        _ transition: TransitionModel
    ) throws {
        try modelContext.transaction {
            print(transition.transitionDate)
            try transitionRepository.addTransition(transition)
        }
    }

    func editTransition(
        _ transition: TransitionModel
    ) throws {
        try modelContext.transaction {
            try transitionRepository.updateTransition(transition)
        }
    }

    func deleteTransition(
        _ transition: TransitionModel
    ) throws {
        try transitionRepository.deleteTransition(transition.transitionId)
    }
}
