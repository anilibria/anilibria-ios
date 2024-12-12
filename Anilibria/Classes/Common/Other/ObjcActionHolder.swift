//
//  ObjcActionHolder.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.12.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public final class ObjcActionHolder<T> {
    private let storedAction: (Any) -> Void

    public init(action: @escaping (T) -> Void) {
        if let item = () as? T {
            self.storedAction = { _ in
                action(item)
            }
        } else {
            self.storedAction = { item in
                if let item = item as? T {
                    action(item)
                }
            }
        }
    }

    @objc public func action(_ item: Any) {
        storedAction(item)
    }
}
