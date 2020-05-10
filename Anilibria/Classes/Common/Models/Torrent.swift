//
//  Torrent.swift
//  Anilibria
//
//  Created by Иван Морозов on 23.02.2020.
//  Copyright © 2020 Иван Морозов. All rights reserved.
//

import Foundation

public final class Torrent: NSObject, Decodable {
    var id: Int = 0
    var torrentHash: String = ""
    var leechers: Int = 0
    var seeders: Int = 0
    var completed: Int = 0
    var quality: String = ""
    var series: String = ""
    var size: Double = 0
    var url: URL?
    var ctime: Date?

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { values in
            id <- values["id"]
            torrentHash <- values["hash"]
            leechers <- values["leechers"]
            seeders <- values["seeders"]
            completed <- values["completed"]
            quality <- values["quality"]
            series <- values["series"]
            size <- values["size"]
            url <- values["url"] <- URLConverter(Configuration.imageServer)
            ctime <- values["ctime"] <- DateConverter()
        }
    }
}
