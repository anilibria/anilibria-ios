//
//  PromoItem.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct PromoItem: Hashable, Decodable {
    enum Content: Hashable {
        case release(Series)
        case ad(PromoAd)
    }

    let id: String
    let image: URL?
    let info: String
    let content: Content?

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeyString.self)
        let urlConverter = URLConverter(Configuration.imageServer)
        self.id = try container.decode(required: "id")
        self.image = urlConverter.convert(from: container.decode("image", "preview"))
        self.info = container.decode("description") ?? ""

        if let series: Series = container.decode("release") {
            content = .release(series)
        } else if let ad = PromoAd(
            title: container.decode("title"),
            url: urlConverter.convert(from: container.decode("url")),
            urlLabel: container.decode("url_label"),
            adErid: container.decode("ad_erid"),
            adOrigin: container.decode("ad_origin")
        ) {
            content = .ad(ad)
        } else {
            content = nil
        }
    }
}

struct PromoAd: Hashable {
    let title: String
    let url: URL
    let urlLabel: String
    let adErid: String
    let adOrigin: String

    init?(
        title: String?,
        url: URL?,
        urlLabel: String?,
        adErid: String?,
        adOrigin: String?
    ) {
        if let title, let url, let urlLabel, let adErid, let adOrigin {
            self.title = title
            self.url = url
            self.urlLabel = urlLabel
            self.adErid = adErid
            self.adOrigin = adOrigin
        } else {
            return nil
        }
    }

    var info: String {
        "erid: \(adErid) • \(adOrigin)"
    }
}
