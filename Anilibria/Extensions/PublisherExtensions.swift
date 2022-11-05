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
