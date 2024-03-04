//
//  FileManagerExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 04.03.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

extension FileManager {
    func emptyTrash() {
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let trash = directory.appendingPathComponent(".Trash")
            if FileManager.default.fileExists(atPath: trash.path) {
                try? FileManager.default.removeItem(at: trash)
            }
        }
    }
}
