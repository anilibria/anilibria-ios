//
//  DelayedAction.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

public final class DelayedAction {
    private let timer: Timer

    public init(delay: TimeInterval, action: @escaping () -> Void) {
        self.timer = Timer(timeInterval: delay, repeats: false) { _ in
            action()
        }
        RunLoop.main.add(self.timer, forMode: .common)
    }

    deinit {
        self.timer.invalidate()
    }
}
