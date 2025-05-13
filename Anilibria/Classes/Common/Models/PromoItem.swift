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
        case promo(Promo)
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
        let isAd: Bool = container.decode("is_ad") ?? false

        if let series: Series = container.decode("release") {
            content = .release(series)
        } else if !isAd {
            content = .promo(.init(
                title: container.decode("title"),
                url: urlConverter.convert(from: container.decode("url"))
            ))
        } else if let ad = PromoAd(
            title: container.decode("title"),
            url: urlConverter.convert(from: container.decode("url")),
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
    let adErid: String
    let adOrigin: String

    init?(
        title: String?,
        url: URL?,
        adErid: String?,
        adOrigin: String?
    ) {
        if let title, let url, let adErid, let adOrigin {
            self.title = title
            self.url = url
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

struct Promo: Hashable {
    let title: String?
    let url: URL?
}
