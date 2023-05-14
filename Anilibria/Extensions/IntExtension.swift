//
//  IntExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 14.05.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

extension Int64 {
    var binaryCountFormatted: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .binary)
    }
}

extension Int {
    var binaryCountFormatted: String {
        Int64(self).binaryCountFormatted
    }
}
