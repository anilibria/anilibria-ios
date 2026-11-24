//
//  FeedbackGenerator.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public struct FeedbackGenerator {

    public static let `default` = FeedbackGenerator()

    private init() {}

    public func produce(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
}
