//
//  Images.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.06.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

extension UIImage {
    enum System {
        private static func create(system: String) -> UIImage {
            UIImage(systemName: system) ?? UIImage()
        }

        static var book: UIImage { create(system: "book") }
        static var play: UIImage { create(system: "play.fill") }
        static var pause: UIImage { create(system: "pause.fill") }
        static var share: UIImage { create(system: "square.and.arrow.up") }
        static var search: UIImage { create(system: "magnifyingglass") }
        static var news: UIImage { create(system: "newspaper") }
        static var history: UIImage { create(system: "memories") }

        static var dots: UIImage {
            create(system: "ellipsis")
                .applyingSymbolConfiguration(.init(weight: .black)) ?? UIImage()
        }

        static var web: UIImage {
            create(system: "network")
                .applyingSymbolConfiguration(.init(weight: .bold)) ?? UIImage()
        }

        static var refresh: UIImage {
            create(system: "arrow.clockwise")
                .applyingSymbolConfiguration(.init(scale: .medium)) ?? UIImage()
        }

        enum Chevrone {
            static var right: UIImage { create(system: "chevron.right") }
            static var down: UIImage { create(system: "chevron.down") }
        }
    }
}
