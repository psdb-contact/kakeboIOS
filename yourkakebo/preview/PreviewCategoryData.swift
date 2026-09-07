//
//  CategoryTestData.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

//
//  PreviewCategoryData.swift
//  yourkakebo
//

import Foundation

@MainActor
enum PreviewCategoryData {

    static func make() -> [CategoryModel] {
        [
            CategoryModel(
                categoryName: "食費",
                transitionType: .expense,
                colorHex: 0xFFEF5350,
                sortOrder: 0
            ),
            CategoryModel(
                categoryName: "日用品",
                transitionType: .expense,
                colorHex: 0xFFFFA726,
                sortOrder: 1
            ),
            CategoryModel(
                categoryName: "交通費",
                transitionType: .expense,
                colorHex: 0xFF42A5F5,
                sortOrder: 2
            ),
            CategoryModel(
                categoryName: "娯楽",
                transitionType: .expense,
                colorHex: 0xFFAB47BC,
                sortOrder: 3
            ),
            CategoryModel(
                categoryName: "光熱費",
                transitionType: .expense,
                colorHex: 0xFF26A69A,
                sortOrder: 4
            ),
            CategoryModel(
                categoryName: "通信費",
                transitionType: .expense,
                colorHex: 0xFF5C6BC0,
                sortOrder: 5
            ),
            CategoryModel(
                categoryName: "家賃",
                transitionType: .expense,
                colorHex: 0xFF78909C,
                sortOrder: 6
            ),
            CategoryModel(
                categoryName: "医療費",
                transitionType: .expense,
                colorHex: 0xFFEC407A,
                sortOrder: 7
            ),
            CategoryModel(
                categoryName: "その他",
                transitionType: .expense,
                colorHex: 0xFF8D6E63,
                sortOrder: 8
            ),
            CategoryModel(
                categoryName: "給与",
                transitionType: .income,
                colorHex: 0xFF66BB6A,
                sortOrder: 0
            ),
            CategoryModel(
                categoryName: "副業",
                transitionType: .income,
                colorHex: 0xFF29B6F6,
                sortOrder: 1
            ),
            CategoryModel(
                categoryName: "その他収入",
                transitionType: .income,
                colorHex: 0xFF9CCC65,
                sortOrder: 2
            )
        ]
    }
}
