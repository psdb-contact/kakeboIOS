//
//  PreviewTemplateData.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/08/29.
//

import Foundation

enum PreviewTemplateData {
    
    static func make() ->   [TemplateModel] {
        [
        TemplateModel(
            category: PreviewCategoryData.make()[0],
            sortOrder: 0
        ),
        TemplateModel(
            category: PreviewCategoryData.make()[1],
            sortOrder: 1
        ),
        TemplateModel(
            category: PreviewCategoryData.make()[2],
            sortOrder: 2
        ),
        TemplateModel(
            category: PreviewCategoryData.make()[3],
            sortOrder: 3
        ),
        TemplateModel(
            category: PreviewCategoryData.make()[4],
            sortOrder: 4
        )
    ]
}
}
