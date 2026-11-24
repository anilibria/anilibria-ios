//
//  AttributedConverter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 20.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public final class AttributedConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = NSAttributedString?

    private let css: String

    init(css: String = "") {
        self.css = css
    }

    public func convert(from item: String?) -> NSAttributedString? {
        return item?.html2AttributedString(with: self.css)
    }
}
