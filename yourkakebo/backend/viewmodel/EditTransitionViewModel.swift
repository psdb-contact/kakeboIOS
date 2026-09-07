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
    var addingTransition: TransitionInputData?
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
        
        resetAddingAmount()
        
        selectedDate = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: selectedDate
        ) ?? selectedDate
    }
    
    func setEditingTransitionId(id: UUID) {
        resetAddingAmount()

        editingTransitionID = id
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
    
    func addAmount(at index: Int) throws {
        let data = transitions[index]
        
        guard let addingAmount = data.addingAmount,
              addingAmount > 0 else {
            resetAddingAmount()

                return
        }
        
        let currentAmount = data.editingAmount ?? data.amount
        let newAmount = currentAmount + addingAmount
        
        if let transition = data.transition {

            try transitionService.editTransition(id: transition.transitionId, amount: newAmount)
        
            transitions[index].transition?.amount = newAmount
        } else {
            let newTransition = TransitionModel(
                amount: newAmount,
                transitionType: data.category.transitionType,
                transitionDate: selectedDate,
                createdAt: Date(),
                category: data.category
            )

            try transitionService.addTransition(newTransition)
            
            transitions[index].transition = newTransition
        }
        
        transitions[index].editingAmount = newAmount
        transitions[index].amount = newAmount
        transitions[index].addingAmount = nil
        transitions[index].isAddingAmount = false
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
            try transitionService.editTransition(
                id: transition.transitionId,
                amount: amount
            )
            
            transitions[index].transition?.amount = amount
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
            
            transitions[index].transition = newTransition
        }

        transitions[index].amount = amount
        transitions[index].editingAmount = amount
        self.editingTransitionID = nil
    }
    
    func setAddingAmount(for id: UUID) {
        for index in transitions.indices {
            if transitions[index].id == id {
                transitions[index].isAddingAmount = true
            } else {
                transitions[index].isAddingAmount = false
                transitions[index].addingAmount = nil
            }
        }
    }
    
    func setShowSelectedCategory() {
        resetAddingAmount()
        showSelectCategory = true
    }
    
    func resetAddingAmount() {
        for index in transitions.indices {
            transitions[index].isAddingAmount = false
            transitions[index].addingAmount = nil
        }
    }
}

// MARK: - View Data

struct TransitionInputData: Identifiable {

    let id = UUID()

    let category: CategoryModel
    var transition: TransitionModel?
    let isTemplate: Bool
    
    var amount: Int
    var editingAmount: Int?
    
    var isAddingAmount = false
    var addingAmount: Int?
}
