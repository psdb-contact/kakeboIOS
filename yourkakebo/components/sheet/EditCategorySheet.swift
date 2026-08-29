//
//  EditCategorySheet.swift
//  yourkakebo
//

import SwiftUI

struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditCategoryViewModel

    init(
        categoryModel: CategoryModel?,
        categoryService: CategoryService
    ) {
        _viewModel = State(
            initialValue: EditCategoryViewModel(
                category: categoryModel,
                categoryService: categoryService
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {


            HStack {
                Button("キャンセル") {
                    dismiss()
                }

                Spacer()

                Text(
                    viewModel.category != nil
                    ? "カテゴリ追加"
                    : "カテゴリ編集"
                )
                .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button("保存") {
                    save()
                }
                .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .frame(height: 56)

            Divider()

            // MARK: - Form

            VStack(spacing: 24) {

                // カテゴリ名
                VStack(alignment: .leading, spacing: 8) {
                    Text("カテゴリ名")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    TextField(
                        "カテゴリ名",
                        text: $viewModel.categoryName
                    )
                    .textFieldStyle(.roundedBorder)
                }

                // 収支タイプ
                VStack(alignment: .leading, spacing: 8) {
                    Text("種類")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    Picker(
                        "種類",
                        selection: $viewModel.transitionType
                    ) {
                        Text("支出")
                            .tag(TransitionType.expense)

                        Text("収入")
                            .tag(TransitionType.income)
                    }
                    .pickerStyle(.segmented)
                }

                // 色
                /*
                ForEach(categoryColors, id: \.self) { colorHex in
                    Button {
                        viewModel.colorHex = colorHex
                    } label: {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 44, height: 44)
                    }
                }
                 */

                Spacer()
            }
            .padding(20)

        }
    }

    private func save() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            print("カテゴリ保存に失敗しました: \(error)")
        }
    }
}
