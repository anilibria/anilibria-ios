//
//  URLExtensions.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

public extension URL {
    static func homeDirectoryHasFreeSpace(minCapacity: Int) -> Bool {
        return URL(fileURLWithPath: NSHomeDirectory()).hasFreeSpace(minCapacity: minCapacity)
    }

    func hasFreeSpace(minCapacity: Int) -> Bool {
        let values = try? self.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        if let capacity = values?.volumeAvailableCapacity, capacity > minCapacity {
            return true
        }
        return false
    }
}
