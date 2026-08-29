//
//  HistoryDetailsSheet.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import SwiftUI

struct HistoryDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: HistoryDetailsSheetViewModel
    
    init(
        transitionService: TransitionService,
        fixedTransitionService: FixedTransitionService
    ) {
        
    }
}
