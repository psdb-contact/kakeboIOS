//
//  BudgetSettingView.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/17.
//

import SwiftUI
import SwiftData

struct FixedTransitionSettingView: View {
    @Environment(AppContainer.self)
    private var appContainer
    
    var body: some View {
        FixedTransitionSettingContentView(
            fixedTransitionService: appContainer.fixedTransitionService,
            categoryService: appContainer.categoryService
        )
    }
}

private struct FixedTransitionSettingContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let fixedTransitionService: FixedTransitionService
    private let categoryService: CategoryService
    
    @Query
    private var fixedTransitions: [FixedTransitionModel]
    
    @State private var viewModel: FixedTransitionSettingViewModel
    
    init(fixedTransitionService: FixedTransitionService, categoryService: CategoryService) {
        self.fixedTransitionService = fixedTransitionService
        self.categoryService = categoryService
        
        _viewModel = State(initialValue: FixedTransitionSettingViewModel(
        )
        )
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 0) {
            switch viewModel.screenType {
            case .list:
                FixedTransitionListScreen(                )
            case .calendar:
                FixedTransitionCalendarScreen(                )
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
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    toggleButton(
                        icon: "list.bullet",
                        value: .list
                    )
                    
                    toggleButton(
                        icon: "calendar",
                        value: .calendar
                    )
                }
                .padding(4)
                .background {
                    if #available(iOS 26.0, *) {
                        Capsule()
                            .glassEffect()
                    } else {
                        Capsule()
                            .fill(.thinMaterial)
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditFixedTransitionView(
                        fixedTransition: nil,
                        fixedTransitionService:  fixedTransitionService,
                        categoryService: categoryService
                    )
                } label: {
                    Image(systemName: "plus")
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
        }
    }
    
    private func toggleButton(
        icon: String,
        value: FixedTransitionScreenType
    ) -> some View {
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.screenType = value
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 17))
                .frame(
                    width: 40,
                    height: 36
                )
                .foregroundStyle(
                    viewModel.screenType == value
                    ? .primary
                    : .secondary
                )
                .background {
                    if viewModel.screenType == value {
                        Capsule()
                            .fill(.white.opacity(0.35))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
