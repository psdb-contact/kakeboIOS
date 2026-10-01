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
    
    func getAllTransitionsByTransitionType(_ transitionType: TransitionType) throws -> [TransitionModel] {
        try transitionRepository.getAllTransitionsByTransitionType(transitionType)
    }

    func getAllTransitionsByDate(
        _ date: Date
    ) throws -> [TransitionModel] {
        try transitionRepository.getAllTransitionsByDate(date)
    }
    
    func getTransitionsByDateAndTransitionType(date: Date, transitionType: TransitionType) throws -> [TransitionModel] {
        try transitionRepository.getTransitionsByDateAndTransitionType(date: date, transitionType: transitionType)
    }

    func addTransition(
        _ transition: TransitionModel
    ) throws {
        try modelContext.transaction {
            print(transition.transitionDate)
            try transitionRepository.insertTransition(transition)
        }
    }

    func editTransition(
        id: UUID,
        amount: Int
    ) throws {
        try modelContext.transaction {
            try transitionRepository.updateAmount(
                id: id,
                amount: amount
            )
        }
    }

    func deleteTransition(
        _ transition: TransitionModel
    ) throws {
        try transitionRepository.deleteTransition(transition.transitionId)
    }
}
