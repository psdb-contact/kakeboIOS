//
//  EditTransitionViewModel.swift
//  yourkakebo
//

import Foundation
import Observation

@Observable
final class EditTransitionViewModel {

    let transitionService: TransitionService
    private let templateService: TemplateService
    

    // MARK: - State
    var transitions: [TransitionInputData] = []
    var showSelectCategory = false
    var showEditTransition = false
    var editingDataId: UUID? = nil
    var editingTransition: TransitionModel? = nil
    var editingCategory: CategoryModel? = nil
    
    var transitionPeriod: TransitionPeriod

    // MARK: - Init

    init(
        transitionService: TransitionService,
        templateService: TemplateService
    ) {
        self.transitionService = transitionService
        self.templateService = templateService
        
        let calendar = Calendar.current
        self.transitionPeriod = TransitionPeriod(type: .expense, date: calendar.startOfDay(for: Date()))
    }

    // MARK: - Action

    func moveDate(by value: Int) {
        
        let date = Calendar.current.date(
            byAdding: .day,
            value: value,
            to: transitionPeriod.date
        ) ?? transitionPeriod.date
        
        transitionPeriod = TransitionPeriod(type: transitionPeriod.type, date: date)
    }

    func load(transitionPeriod: TransitionPeriod) throws {
        let templates = try templateService.getAllTemplatesByTransitionType(transitionPeriod.type)
        let dateTransitions = try transitionService.getTransitionsByDateAndTransitionType(date: transitionPeriod.date, transitionType: transitionPeriod.type)

        
        // MARK: Transition Map

        let transitionMap: [UUID: TransitionModel] = Dictionary(
            uniqueKeysWithValues: dateTransitions.compactMap {
                transition -> (UUID, TransitionModel)? in

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

        let templateMap: [UUID: TemplateModel] = Dictionary(
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

            result.append(
                TransitionInputData(
                    category: category,
                    transition: transition,
                    isTemplate: template != nil,
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
    
    func refreash(_ transition: TransitionModel) {
        guard let index = transitions.firstIndex(
            where: { $0.id == editingDataId }
        ) else {
            return
        }
                    
        transitions[index].transition = transition
    }
    
    func setTransitionPeriodType(_ transitionType: TransitionType) {
        transitionPeriod = TransitionPeriod(type: transitionType, date: transitionPeriod.date)
    }
    
    func setShowSelectedCategory() {
        showSelectCategory = true
    }
}

// MARK: - View Data

struct TransitionInputData: Identifiable {

    let id = UUID()

    let category: CategoryModel
    var transition: TransitionModel?
    let isTemplate: Bool
}
