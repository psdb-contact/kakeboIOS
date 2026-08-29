//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditTransitionViewModel {

    private let transitionService: TransitionService
    private let templateService: TemplateService
    

    // MARK: - State

    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var transitions: [TransitionInputData] = []
    var showSelectCategory = false
    var editingTransitionID: UUID?
    var isSaving = false

    // MARK: - Init

    init(
        transitionService: TransitionService,
        templateService: TemplateService
    ) {
        self.transitionService = transitionService
        self.templateService = templateService
    }

    // MARK: - Action

    func moveDate(by value: Int) {
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: selectedDate
        ) ?? selectedDate
    }

    func loadTransitions() throws {
        let templates = try templateService.getAllTemplates()
        let dateTransitions = try transitionService.getAllTransitionsByDate(selectedDate)

        
        // MARK: Transition Map

        let transitionMap: [String: TransitionModel] = Dictionary(
            uniqueKeysWithValues: dateTransitions.compactMap {
                transition -> (String, TransitionModel)? in

                guard let category = transition.category else {
                    return nil
                }

                return (
                    category.categoryId,
                    transition
                )
            }
        )

        // MARK: Template Map

        let templateMap: [String: TemplateModel] = Dictionary(
            uniqueKeysWithValues: templates.map {
                (
                    $0.category.categoryId,
                    $0
                )
            }
        )

        // MARK: Category IDs

        let allCategoryIds = Set(
            transitionMap.keys
        ).union(
            templateMap.keys
        )

        var result: [TransitionInputData] = []

        // MARK: Create View Data

        for categoryId in allCategoryIds {

            let transition = transitionMap[categoryId]
            let template = templateMap[categoryId]

            // TransitionがあればTransition側のCategory、
            // なければTemplate側のCategoryを使用する。
            guard let category = (
                transition?.category
                ?? template?.category
            ) else {
                continue
            }

            let amount = transition?.amount ?? 0

            result.append(
                TransitionInputData(
                    category: category,
                    transition: transition,
                    isTemplate: template != nil,
                    amount: amount,
                    editingAmount: amount
                )
            )
        }

        // MARK: Sort
        //
        // TemplateのsortOrder順。
        // Templateに存在しないCategoryは最後。

        result.sort { lhs, rhs in
            let lhsSortOrder = templateMap[
                lhs.category.categoryId
            ]?.sortOrder ?? 9999

            let rhsSortOrder = templateMap[
                rhs.category.categoryId
            ]?.sortOrder ?? 9999

            return lhsSortOrder < rhsSortOrder
        }

        transitions = result
    }

    func saveTransition() throws {
        guard let editingTransitionID else {
            return
        }

        guard let index = transitions.firstIndex(
            where: { $0.id == editingTransitionID }
        ) else {
            return
        }

        let data = transitions[index]

        let amount = data.editingAmount ?? data.amount

        if let transition = data.transition {
            transition.amount = amount
            transition.transitionDate = selectedDate

            try transitionService.editTransition(
                transition
            )
        } else {
            let newTransition = TransitionModel(
                amount: amount,
                transitionType: data.category.transitionType,
                transitionDate: selectedDate,
                createdAt: Date(),
                category: data.category
            )

            try transitionService.addTransition(
                newTransition
            )
        }

        transitions[index].editingAmount = amount
        self.editingTransitionID = nil
    }
}

// MARK: - View Data

struct TransitionInputData: Identifiable {

    let id = UUID()

    let category: CategoryModel
    let transition: TransitionModel?
    let isTemplate: Bool
    
    let amount: Int
    var editingAmount: Int?
}
