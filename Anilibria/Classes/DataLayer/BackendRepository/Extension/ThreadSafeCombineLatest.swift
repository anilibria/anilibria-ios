//
//  ThreadSafeCombineLatest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

public final class LockedAtomic<Value> {
    private let lock = NSRecursiveLock()
    private var value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public func load() -> Value {
        lock.sync { value }
    }

    public func store(_ desired: Value) {
        lock.sync { value = desired }
    }

    public func exchange(_ desired: Value) -> Value {
        lock.sync {
            let old = value
            value = desired
            return old
        }
    }
}

extension NSRecursiveLock {
    public func sync<R>(_ body: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try body()
    }
}

extension Publishers {
    public struct ThreadSafeCombineLatest<A, B>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure {

        public typealias Output = (A.Output, B.Output)

        public typealias Failure = A.Failure

        public let a: A

        public let b: B

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        public func receive<S: Subscriber>(subscriber: S) where B.Failure == S.Failure, S.Input == (A.Output, B.Output) {
            let s = Inner(pub: self, sub: subscriber)
            subscriber.receive(subscription: s)
        }
    }
}

private struct CombineLatestState: OptionSet {
    let rawValue: Int

    static let aCompleted = CombineLatestState(rawValue: 1 << 0)
    static let bCompleted = CombineLatestState(rawValue: 1 << 1)

    static let initial: CombineLatestState = []
    static let completed: CombineLatestState = [.aCompleted, .bCompleted]

    var isACompleted: Bool {
        return self.contains(.aCompleted)
    }

    var isBCompleted: Bool {
        return self.contains(.bCompleted)
    }

    var isCompleted: Bool {
        return self == .completed
    }
}

extension Publishers.ThreadSafeCombineLatest {

    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        B.Failure == S.Failure,
        S.Input == (A.Output, B.Output) {

        typealias Pub = Publishers.ThreadSafeCombineLatest<A, B>
        typealias Sub = S

        private let lock = NSRecursiveLock()
        let sub: Sub

        enum Source: Int {
            case a = 1
            case b = 2
        }

        var state: CombineLatestState = .initial

        var childA: Child<A.Output>?
        var childB: Child<B.Output>?

        var outputA: A.Output?
        var outputB: B.Output?

        var demand: Subscribers.Demand = .none

        init(pub: Pub, sub: Sub) {
            self.sub = sub

            let childA = Child<A.Output>(parent: self, source: .a)
            pub.a.subscribe(childA)
            self.childA = childA

            let childB = Child<B.Output>(parent: self, source: .b)
            pub.b.subscribe(childB)
            self.childB = childB
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.lock.lock()
            if self.state == .completed {
                self.lock.unlock()
                return
            }

            self.demand += demand

            let childA = self.childA
            let childB = self.childB
            self.lock.unlock()

            childA?.request(demand)
            childB?.request(demand)
        }

        func cancel() {
            self.lock.lock()
            self.state = .completed
            let (childA, childB) = self.release()
            self.lock.unlock()

            childA?.cancel()
            childB?.cancel()
        }

        private func release() -> (Child<A.Output>?, Child<B.Output>?) {
            defer {
                self.outputA = nil
                self.outputB = nil

                self.childA = nil
                self.childB = nil
            }
            return (self.childA, self.childB)
        }

        func childReceive(_ value: Any, from source: Source) -> Subscribers.Demand {
            self.lock.lock()
            let action = CombineLatestState(rawValue: source.rawValue)
            if self.state.contains(action) {
                self.lock.unlock()
                return .none
            }

            switch source {
            case .a:
                self.outputA = value as? A.Output
            case .b:
                self.outputB = value as? B.Output
            }

            if self.demand == 0 {
                self.lock.unlock()
                return .none
            }

            switch (self.outputA, self.outputB) {
            case (.some(let a), .some(let b)):
                self.demand -= 1
                self.lock.unlock()
                let more = self.sub.receive((a, b))
                // Apple's Combine doesn't strictly support sync backpressure.
                self.lock.lock()
                self.demand += more
                self.lock.unlock()
                return .none
            default:
                self.lock.unlock()
                return .none
            }
        }

        func childReceive(completion: Subscribers.Completion<A.Failure>, from source: Source) {
            let action = CombineLatestState(rawValue: source.rawValue)

            self.lock.lock()
            if self.state.contains(action) {
                self.lock.unlock()
                return
            }

            switch completion {
            case .failure:
                self.state = .completed
                let (childA, childB) = self.release()
                self.lock.unlock()

                childA?.cancel()
                childB?.cancel()
                self.sub.receive(completion: completion)
            case .finished:
                self.state.insert(action)
                if self.state.isCompleted {
                    let (childA, childB) = self.release()
                    self.lock.unlock()

                    childA?.cancel()
                    childB?.cancel()
                    self.sub.receive(completion: completion)
                } else {
                    self.lock.unlock()
                }
            }
        }

        var description: String {
            return "CombineLatest"
        }

        var debugDescription: String {
            return "CombineLatest"
        }

        final class Child<Output>: Subscriber {

            typealias Parent = Inner
            typealias Input = Output
            typealias Failure = A.Failure

            let subscription = LockedAtomic<Subscription?>(nil)
            let parent: Parent
            let source: Source

            init(parent: Parent, source: Source) {
                self.parent = parent
                self.source = source
            }

            func receive(subscription: Subscription) {
                self.subscription.exchange(subscription)?.cancel()
            }

            func receive(_ input: Input) -> Subscribers.Demand {
                guard self.subscription.load() != nil else {
                    return .none
                }
                return self.parent.childReceive(input, from: self.source)
            }

            func receive(completion: Subscribers.Completion<Failure>) {
                guard let subscription = self.subscription.exchange(nil) else {
                    return
                }

                subscription.cancel()
                self.parent.childReceive(completion: completion, from: self.source)
            }

            func cancel() {
                self.subscription.exchange(nil)?.cancel()
            }

            func request(_ demand: Subscribers.Demand) {
                self.subscription.load()?.request(demand)
            }
        }
    }
}

public extension Publisher {
    func threadSafeCombineLatest<P: Publisher>(_ publisher: P) -> Publishers.ThreadSafeCombineLatest<Self, P> where P.Failure == Failure {
        Publishers.ThreadSafeCombineLatest(self, publisher)
    }
}
