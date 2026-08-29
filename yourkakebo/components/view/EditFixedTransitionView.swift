
import SwiftUI

struct EditFixedTransitionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: EditFixedTransitionViewModel
    
    private let cycleOptions: [CycleOptionType] = [
        .daily,
        .weekday,
        .weekly(1),
        .weekly(2),
        .weekly(3),
        .monthly(1),
        .monthly(2),
        .monthly(3),
        .monthly(4),
        .monthly(5),
        .monthly(6),
        .yearly
    ]
    
    init (
        fixedTransition: FixedTransitionModel?,
        fixedTransitionService: FixedTransitionService,
        categoryService: CategoryService
    ) {
        _viewModel = State(initialValue: EditFixedTransitionViewModel(fixedTransition: fixedTransition, fixedTransitionService: fixedTransitionService, categoryService: categoryService))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {

            ScrollView {
                VStack(spacing: 16) {
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("固定出費名")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                        TextField(
                            "固定出費名",
                            text: $viewModel.fixedTransitionName
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("金額")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                        TextField(
                            "金額",
                            value: $viewModel.amount,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.showCategorySheet = true
                        } label: {
                            HStack {
                                Text("カテゴリ")
                                    .frame(width: 108, alignment: .leading)
                                Spacer()
                                
                                Text(viewModel.category?.categoryName ?? "未選択")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(height: 52)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.editingCycleOptionType = viewModel.cycleOptionType
                            viewModel.showCycleTypeSheet = true
                        } label: {
                            HStack {
                                Text("繰り返しのルール")
                                    .frame(width: 108, alignment: .leading)
                                Spacer()
                                
                                Text(viewModel.cycleOptionType.displayString)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(height: 52)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.showStartDateSheet = true
                        } label: {
                            HStack {
                                Text("開始日")
                                    .frame(width: 108, alignment: .leading)
                                Spacer()
                                
                                Text(
                                    viewModel.startDate
                                        .formatted(
                                            .dateTime
                                                .locale(Locale(identifier: "ja_JP"))
                                                .year()
                                                .month()
                                                .day()
                                        )
                                )                            .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(height: 52)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.showEndDateSheet = true
                        } label: {
                            HStack {
                                Text("終了日")
                                    .frame(width: 108, alignment: .leading)
                                Spacer()
                                
                                Text(
                                    viewModel.endDate?
                                        .formatted(
                                            .dateTime
                                                .locale(Locale(identifier: "ja_JP"))
                                                .year()
                                                .month()
                                                .day()
                                        )
                                    ?? "未選択"
                                )
                                .lineLimit(1)
                                .truncationMode(.tail)
                            }
                            .frame(height: 52)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.showHolidayTypeSheet = true
                        } label: {
                            HStack {
                                Text("土日祝の場合")
                                    .frame(width: 108, alignment: .leading)
                                Spacer()
                                
                                Text(viewModel.cycleHolidayType.displayString)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(height: 52)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    save()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            Color(
                                red: 0.27,
                                green: 0.27,
                                blue: 0.27
                            )
                        )
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                } label: {
                    Image(systemName: "xmark")
                }
                
                Spacer()
                
                Button() {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .sheet(isPresented: $viewModel.showCategorySheet) {
            NavigationStack {
                Picker(
                    "カテゴリ",
                    selection: Binding(
                        get: {
                            viewModel.category?.categoryId
                        },
                        set: { newCategoryId in
                            viewModel.editingCategory = viewModel.categories.first {
                                $0.categoryId == newCategoryId
                            }
                        }
                    )
                ) {
                    ForEach(viewModel.categories,  id: \.categoryId) { category in
                        Text(category.categoryName)
                            .tag(Optional(category.categoryId))
                    }
                }
                .pickerStyle(.wheel)
                .navigationTitle("カテゴリ")
                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showCategorySheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let category = viewModel.editingCategory {
                                viewModel.category = category
                            }
                            viewModel.showCategorySheet = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented:$viewModel.showCycleTypeSheet ) {
            NavigationStack {
                Picker("繰り返しのルール", selection: Binding(
                    get: {
                        viewModel.editingCycleOptionType!
                    },
                    set: {
                        viewModel.editingCycleOptionType = $0
                    }
                ) ){
                    ForEach(cycleOptions, id: \.self) { option in
                        Text(option.displayString)
                            .tag(option)
                    }
                }
                .pickerStyle(.wheel)
                .navigationTitle("繰り返しのルール")
                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showCycleTypeSheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.cycleOptionType = viewModel.editingCycleOptionType!
                            viewModel.showCycleTypeSheet = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showStartDateSheet) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "開始日",
                        selection: Binding(
                            get: {
                                viewModel.editingStartDate ??  viewModel.startDate
                            },
                            set: {
                                viewModel.editingStartDate = $0
                            }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .navigationTitle("開始日")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .navigationTitle("開始日")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showStartDateSheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let date = viewModel.editingStartDate {
                                viewModel.startDate = date
                            }
                            viewModel.showStartDateSheet = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showEndDateSheet) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "終了日",
                        selection: Binding(
                            get: {
                                viewModel.editingEndDate ??  viewModel.endDate ?? Date()
                            },
                            set: {
                                viewModel.editingEndDate = $0
                            }
                        ),                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .navigationTitle("終了日")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.showEndDateSheet = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                if let date = viewModel.editingEndDate {
                                    viewModel.endDate = date
                                }
                                viewModel.showEndDateSheet = false
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                .navigationTitle("開始日")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showHolidayTypeSheet) {
            NavigationStack {
                Picker("休日の扱い", selection:  Binding(
                    get: {
                        viewModel.editingCycleHoliday ?? viewModel.cycleHolidayType
                    },
                    set: {
                        viewModel.editingCycleHoliday = $0
                    }
                ) ){
                    ForEach(CycleHolidayType.allCases, id: \.self) { option in
                        Text(option.displayString)
                            .tag(option)
                    }
                }
                .pickerStyle(.wheel)
                .navigationTitle("休日の扱い")
                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.showHolidayTypeSheet = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let type = viewModel.editingCycleHoliday {
                                viewModel.cycleHolidayType = type
                            }
                            viewModel.showHolidayTypeSheet = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .task{
            do {
                try viewModel.load()
            }
            catch{
                print("Ctegoryの読み込みに失敗しました: \(error)")
            }
        }
    }
    
    private func save() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            print("固定出費の保存に失敗しました: \(error)")
        }
    }
}
