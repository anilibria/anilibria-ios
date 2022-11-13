//
//  Hasher.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import CommonCrypto

extension Array where Element == UInt8 {
    func asString() -> String {
        var output = ""
        for thisChar in self {
            if (thisChar == 0x20) {
               output += "+"
            } else if (thisChar == 0x2e || thisChar == 0x2d || thisChar == 0x5f || thisChar == 0x7e ||
                       (thisChar >= 0x61 && thisChar <= 0x7a) ||
                       (thisChar >= 0x41 && thisChar <= 0x5a) ||
                       (thisChar >= 0x30 && thisChar <= 0x39)) {
                output += String(format: "%c", thisChar)
            } else {
                output += String(format: "%%%02X", thisChar)
            }
        }
        return output
    }
}

extension Data {
    func sha1() -> [UInt8] {
        let data = self
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest
    }
}
