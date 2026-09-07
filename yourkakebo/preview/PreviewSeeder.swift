//
//  PreviewSeeder.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import SwiftData
import Foundation

@MainActor
enum PreviewSeeder {
    
    static func seed(
        context: ModelContext
    ) {
        do {

            for category in PreviewCategoryData.make() {
                context.insert(category)
            }

            for fixedTransition in PreviewFixedTransitionData.make() {
                context.insert(fixedTransition)
            }

            for transition in PreviewTransitionData.make() {
                context.insert(transition)
            }

            for budget in PreviewBudgetData.make() {
                context.insert(budget)
            }

            for template in PreviewTemplateData.make() {
                context.insert(template)
            }

            try context.save()

        } catch {
            print("PreviewSeeder error:", error)
        }
    }
}
