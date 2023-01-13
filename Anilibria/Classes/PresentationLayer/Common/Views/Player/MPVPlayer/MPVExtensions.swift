//
//  MPVExtensions.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.01.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

extension UnsafePointer<CChar> {
    var asString: String {
        String(cString: self)
    }
}

extension String {
    var asUnsafeCString: UnsafePointer<CChar>? {
        let count = self.utf8CString.count
        let result: UnsafeMutableBufferPointer<Int8> = UnsafeMutableBufferPointer<CChar>.allocate(capacity: count)
        _ = result.initialize(from: self.utf8CString)
        return UnsafePointer(result.baseAddress)
    }
}
