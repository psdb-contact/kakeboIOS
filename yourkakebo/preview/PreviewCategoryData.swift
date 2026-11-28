import Foundation

@MainActor
enum PreviewCategoryData {

    static func make() -> [CategoryModel] {
        [
            CategoryModel(
                categoryName: "食費",
                transitionType: .expense,
                colorHex: 0xFFFF6B6B,
                isDisplayed: true,
                sortOrder: 0
            ),
            CategoryModel(
                categoryName: "日用品",
                transitionType: .expense,
                colorHex: 0xFFFF8E53,
                isDisplayed: true,
                sortOrder: 1
            ),
            CategoryModel(
                categoryName: "交通費",
                transitionType: .expense,
                colorHex: 0xFFFFB347,
                isDisplayed: true,
                sortOrder: 2
            ),
            CategoryModel(
                categoryName: "娯楽",
                transitionType: .expense,
                colorHex: 0xFFFFD93D,
                isDisplayed: false,
                sortOrder: 3
            ),
            CategoryModel(
                categoryName: "光熱費",
                transitionType: .expense,
                colorHex: 0xFFC6E377,
                isDisplayed: false,
                sortOrder: 4
            ),
            CategoryModel(
                categoryName: "通信費",
                transitionType: .expense,
                colorHex: 0xFF7ED957,
                isDisplayed: false,
                sortOrder: 5
            ),
            CategoryModel(
                categoryName: "家賃",
                transitionType: .expense,
                colorHex: 0xFF38D39F,
                sortOrder: 6
            ),
            CategoryModel(
                categoryName: "医療費",
                transitionType: .expense,
                colorHex: 0xFF2DD4BF,
                sortOrder: 7
            ),
            CategoryModel(
                categoryName: "その他",
                transitionType: .expense,
                colorHex: 0xFF36CFC9,
                isDisplayed: true,
                sortOrder: 8
            ),
            CategoryModel(
                categoryName: "給与",
                transitionType: .income,
                colorHex: 0xFF4FC3F7,
                sortOrder: 0
            ),
            CategoryModel(
                categoryName: "副業",
                transitionType: .income,
                colorHex: 0xFF5AA9FF,
                sortOrder: 1
            ),
            CategoryModel(
                categoryName: "その他収入",
                transitionType: .income,
                colorHex: 0xFF7C83FD,
                sortOrder: 2
            )
        ]
    }
}
