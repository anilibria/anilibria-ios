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
        return EventPublisher(control: self, event: event).eraseToAnyPublisher()
    }
}


extension UIControl {

    class EventSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
        let control: UIControl
        let event: UIControl.Event
        var subscriber: S?

        var currentDemand: Subscribers.Demand = .none

        init(control: UIControl, event: UIControl.Event, subscriber: S) {
            self.control = control
            self.event = event
            self.subscriber = subscriber

            control.addTarget(self,
                              action: #selector(eventRaised),
                              for: event)
        }

        func request(_ demand: Subscribers.Demand) {
            currentDemand += demand
        }

        func cancel() {
            subscriber = nil
            control.removeTarget(self,
                                 action: #selector(eventRaised),
                                 for: event)
        }

        @objc func eventRaised() {
            if currentDemand > 0 {
                currentDemand += subscriber?.receive(()) ?? .none
                currentDemand -= 1
            }
        }
    }
}

extension UIControl {

    struct EventPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Never

        let control: UIControl
        let event: UIControl.Event

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = EventSubscription(control: control, event: event, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}
