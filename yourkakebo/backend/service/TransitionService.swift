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
            try transitionRepository.insertTransition(transition)
        }
    }

    func editTransition(_ transition: TransitionModel) throws {
        try modelContext.transaction {
            try transitionRepository.updateTransition(transition)
        }
    }
    
    func addAndDeleteTransition(add: TransitionModel, delete: TransitionModel) throws {
        try modelContext.transaction {
            try transitionRepository.insertTransition(add)
            try transitionRepository.deleteTransition(delete.transitionId)
        }
    }
    
    func editAndDeleteTransition(edit: TransitionModel, delete: TransitionModel) throws {
        try modelContext.transaction {
            try transitionRepository.updateTransition(edit)
            try transitionRepository.deleteTransition(delete.transitionId)
        }
    }

    func deleteTransition(
        _ transition: TransitionModel
    ) throws {
        try transitionRepository.deleteTransition(transition.transitionId)
    }
}
