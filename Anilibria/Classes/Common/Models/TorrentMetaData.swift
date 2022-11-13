//
//  TorrentMetaData.swift
//  Anilibria
//
//  Created by Иван Морозов on 23.02.2020.
//  Copyright © 2020 Иван Морозов. All rights reserved.
//

import Foundation

public final class TorrentMetaData: NSObject, Decodable {
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
		self.id <- decoder["id"]
		self.torrentHash <- decoder["hash"]
		self.leechers <- decoder["leechers"]
		self.seeders <- decoder["seeders"]
		self.completed <- decoder["completed"]
		self.quality <- decoder["quality"]
		self.series <- decoder["series"]
		self.size <- decoder["size"]
		self.url <- decoder["url"] <- URLConverter(Configuration.imageServer)
		self.ctime <- decoder["ctime"] <- DateConverter()
    }
}
