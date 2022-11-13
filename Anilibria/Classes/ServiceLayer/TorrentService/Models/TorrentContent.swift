//
//  TorrentContent.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

struct TorrentContent {
    let length: Int
    let files: [TorrentFile]

    init(files: [TorrentFile]) {
        self.files = files
        self.length = files.reduce(0, { $0 + $1.length })
    }
}

extension TorrentContent {
    init?(from info: BencodeValue) {
        guard let name = info["name"]?.text else {
            return nil
        }

        let length = info["length"]?.number

        let files = info["files"]?.list?.compactMap({ value -> TorrentFile? in
            guard
                let length = value["length"]?.number,
                var pathArray = value["path"]?.list?.compactMap(\.text),
                !pathArray.isEmpty
            else {
                return nil
            }
            let name = pathArray.removeLast()
            let path = pathArray.joined(separator: "/")
            return TorrentFile(name: name, path: path, length: length)
        }) ?? []

        if !files.isEmpty {
            self.init(files: files)
        } else if let length = length {
            self.init(files: [TorrentFile(name: name, path: "", length: length)])
        } else {
            return nil
        }
    }
}
