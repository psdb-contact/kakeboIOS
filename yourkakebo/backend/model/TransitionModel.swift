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
    var category: CategoryModel?
    var amount: Int
    var transitionType: TransitionType
    var transitionDate: Date
    var createdAt: Date
    var memo: String

    init(
        transitionId: UUID = UUID(),
        category: CategoryModel?,
        amount: Int,
        transitionType: TransitionType,
        transitionDate: Date,
        createdAt: Date,
        memo: String = ""
    ) {
        self.transitionId = transitionId
        self.category = category
        self.amount = amount
        self.transitionType = transitionType
        self.transitionDate = transitionDate
        self.createdAt = createdAt
        self.memo = memo
    }
}

struct TransitionBackup: Encodable, Decodable {
    let transitionId: UUID
    let categoryId: UUID?
    let amount: Int
    let transitionType: TransitionType
    let transitionDate: Date
    let createdAt: Date
    let memo: String
}

extension TransitionBackup {
    init(model: TransitionModel) {
        self.init(
            transitionId: model.transitionId,
            categoryId: model.category?.categoryId,
            amount: model.amount,
            transitionType: model.transitionType,
            transitionDate: model.transitionDate,
            createdAt: model.createdAt,
            memo: model.memo
        )
    }
}

func parseTransitions(_ section: CSVSection) throws -> [TransitionBackup] {
    let index = try makeHeaderIndex(
        section.header,
        expected: [
            "transitionId",
            "categoryId",
            "amount",
            "transitionType",
            "transitionDate",
            "createdAt",
            "memo"
        ]
    )
    
    return try section.rows.map { row in
        TransitionBackup(
            transitionId: try parseUUID(row[index["transitionId"]!]),
            categoryId: try parseOptionalUUID(row[index["categoryId"]!]),
            amount: try parseInt(row[index["amount"]!]),
            transitionType: try parseEnum(row[index["transitionType"]!], as: TransitionType.self),
            transitionDate: try parseDate(row[index["transitionDate"]!]),
            createdAt: try parseDate(row[index["createdAt"]!]),
            memo: row[index["memo"]!])
    }
}
