import Combine
import Foundation

public extension Publisher {
    func afterDone(_ action: @escaping ActionFunc) -> Publishers.HandleEvents<Self> {
        return self.handleEvents(receiveCompletion: { _ in action()})
    }

    func manageActivity(_ activity: ActivityDisposable?) -> Publishers.HandleEvents<Self> {
        return self.afterDone {
            activity?.dispose()
        }
    }

    func `do`(onNext: ((Output) -> Void)?) -> Publishers.HandleEvents<Self> {
        return self.handleEvents(receiveOutput: { value in onNext?(value) })
    }

    func sink(onNext: ((Output) -> Void)? = nil, onError: ((Error) -> Void)? = nil) -> AnyCancellable {
        self.sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                onError?(error)
            }
        } receiveValue: { value in
            onNext?(value)
        }
    }
}

public extension AnyPublisher {
    @frozen enum PromiseResult {
        case send(Output)
        case failure(Failure)
        case completed
    }

    typealias Promise = (PromiseResult) -> Void

    static func create(_ attemptToFulfill: @escaping (@escaping Promise) -> AnyCancellable) -> AnyPublisher<Output, Failure> {
        return PromisePublisher(attemptToFulfill).eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    struct PromisePublisher: Publisher {
        let attemptToFulfill: (@escaping Promise) -> AnyCancellable

        init(_ attemptToFulfill: @escaping (@escaping Promise) -> AnyCancellable) {
            self.attemptToFulfill = attemptToFulfill
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = PromiseSubscription(attemptToFulfill, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension AnyPublisher {
    class PromiseSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        let attemptToFulfill: (@escaping Promise) -> AnyCancellable
        var subscriber: S?
        var cancellable: AnyCancellable?

        init(_ attemptToFulfill: @escaping (@escaping Promise) -> AnyCancellable, subscriber: S) {
            self.attemptToFulfill = attemptToFulfill
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            let promise: Promise = { [weak self] result in
                switch result {
                case .send(let value):
                    _ = self?.subscriber?.receive(value)
                case .failure(let error):
                    self?.subscriber?.receive(completion: .failure(error))
                case .completed:
                    self?.subscriber?.receive(completion: .finished)
                }
            }

            self.cancellable = attemptToFulfill(promise)
        }

        func cancel() {
            subscriber = nil
            cancellable = nil
        }
    }
}
