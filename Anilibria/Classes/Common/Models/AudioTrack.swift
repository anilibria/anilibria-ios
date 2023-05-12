//
//  AudioTrack.swift
//  Anilibria
//
//  Created by Ivan Morozov on 11.05.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

public struct AudioTrack: Codable, Hashable {
    let id: String
    let title: String
}

extension AudioTrack {
    static let rusTrack = AudioTrack(id: "1", title: "AniLibria.TV")
    static let jpnTrack = AudioTrack(id: "2", title: "Оригинал")
    
    static var defaultList: [AudioTrack] = [
        .rusTrack,
        .jpnTrack
    ]
}
