import SwiftData
import Foundation

final class TransitionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getAllTransitions() throws -> [TransitionModel] {
        let descriptor = FetchDescriptor<TransitionModel>(
            sortBy: [SortDescriptor(\.transitionDate)]
        )

        return try modelContext.fetch(descriptor)
    }

    func getAllTransitionsByDate(_ date: Date) throws -> [TransitionModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        )!

        let descriptor = FetchDescriptor<TransitionModel>(
            predicate: #Predicate {
                $0.transitionDate >= startOfDay &&
                $0.transitionDate < endOfDay
            },
            sortBy: [SortDescriptor(\.transitionDate)]
        )

        return try modelContext.fetch(descriptor)
    }

    func addTransition(_ transition: TransitionModel) throws {
        modelContext.insert(transition)
        try modelContext.save()
    }

    func updateTransition(_ transition: TransitionModel) throws {
        try modelContext.save()
    }

    func deleteTransition(_ id: UUID) throws {
        let descriptor = FetchDescriptor<TransitionModel>(
            predicate: #Predicate {
                $0.transitionId == id
            }
        )

        if let transition = try modelContext.fetch(descriptor).first {
            modelContext.delete(transition)
            try modelContext.save()
        }
    }

    func replaceAllTransitions(_ transitions: [TransitionModel]) throws {
        let existingTransitions = try getAllTransitions()

        for transition in existingTransitions {
            modelContext.delete(transition)
        }

        for transition in transitions {
            modelContext.insert(transition)
        }

        try modelContext.save()
    }
}
