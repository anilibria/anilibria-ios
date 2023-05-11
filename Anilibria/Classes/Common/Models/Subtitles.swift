//
//  Subtitles.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.05.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

public struct Subtitles {
    let id: String
    let title: String
}

extension Subtitles {
    static let disable = Subtitles(id: "no", title: "Отключено")
    static let inscriptions = Subtitles(id: "1", title: "Надписи")
    static let fullSubtitles = Subtitles(id: "2", title: "Субтитры")
    
    static var defaultList: [Subtitles] = [
        .fullSubtitles,
        .inscriptions,
        .disable
    ]
}
