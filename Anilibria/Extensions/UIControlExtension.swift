//
//  UIControlExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public extension UIControl {
    func publisher(for event: UIControl.Event) -> AnyPublisher<Void, Never> {
        AnyPublisher<Void, Never>.create { [weak self] promise in
            let holder = ObjcActionHolder { promise(.send(())) }
            self?.addTarget(holder, action: #selector(holder.action), for: event)
            return AnyCancellable {
                self?.removeTarget(holder, action: #selector(holder.action), for: event)
            }
        }
    }
}
