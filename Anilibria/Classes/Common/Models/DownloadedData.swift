//
//  DownloadedData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 26.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Foundation

struct DownloadedData: Codable {
    var episodes: [String: URL] = [:]
}
