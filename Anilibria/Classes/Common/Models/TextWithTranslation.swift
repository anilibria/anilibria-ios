//
//  TextWithTranslation.swift
//  Anilibria
//
//  Created by Ivan Morozov on 30.11.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

struct TextWithTranslation {
    let original: String
    var displayValue: String {
        translation()
    }
    
    private var translation: () -> String
    
    init(original: String, translation: @escaping @autoclosure () -> String) {
        self.original = original
        self.translation = translation
    }
}
