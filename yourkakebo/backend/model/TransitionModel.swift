//
//  TransitionModel.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/13.
//

import SwiftData
import Foundation

@Model
final class TransitionModel {
    @Attribute(.unique) var transitionId: UUID
    var amount: Int
    var transitionType: TransitionType
    var transitionDate: Date
    var createdAt: Date
    var category: CategoryModel?
    var memo: String

    init(
        transitionId: UUID = UUID(),
        amount: Int,
        transitionType: TransitionType,
        transitionDate: Date,
        createdAt: Date,
        category: CategoryModel?,
        memo: String = ""
    ) {
        self.transitionId = transitionId
        self.amount = amount
        self.transitionType = transitionType
        self.transitionDate = transitionDate
        self.createdAt = createdAt
        self.category = category
        self.memo = memo
    }
}
