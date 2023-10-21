import Foundation
import Combine

/**
 * Created on Kotlin by Konstantin Tskhovrebov (aka @terrakok) on 22.07.17.
 * Port to Swift by Morozov Ivan (aka @allui) on 21.03.18
 */

protocol Paging {
    associatedtype Value

    var first: Value { get }
    var current: Value { get }
    func next() -> Value
    func turnNext()
    func reset()
}

final class IntPaging: Paging {
    typealias Value = Int

    var first: Int = 1
    var current: Int = 1

    func next() -> Int {
        return self.current + 1
    }

    func turnNext() {
        self.current = self.next()
    }

    func reset() {
        self.current = self.first
    }
}

public enum PaginatorData<T> {
    case first([T])
    case next([T])
}

final class Paginator<T, P: Paging> {
    private let requestFactory: (P.Value) -> AnyPublisher<[T], Error>
    private let paging: P
    public let handler: Handler<T> = Handler()

    init(_ paging: P, requestFactory: @escaping (P.Value) -> AnyPublisher<[T], Error>) {
        self.requestFactory = requestFactory
        self.paging = paging
    }

    private lazy var currentState: State = EmptyState(self)
    private var subscriber: AnyCancellable?

    func restart() {
        self.currentState.restart()
    }

    func refresh() {
        self.currentState.refresh()
    }

    func loadNewPage() {
        self.currentState.loadNewPage()
    }

    func release() {
        self.currentState.release()
    }

    private func loadPage(_ page: P.Value) {
        self.subscriber = self.requestFactory(page)
            .sink(onNext: { [weak self] in self?.currentState.newData($0) },
                       onError: { [weak self] in self?.currentState.fail($0) })
    }

    private final class EmptyState: State<T, P> {
        override func restart() {
            self.refresh()
        }

        override func refresh() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class EmptyProgressState: State<T, P> {
        override func restart() {
            paginator.loadPage(paginator.paging.first)
        }

        override func newData(_ data: [T]) {
            if !data.isEmpty {
                paginator.currentState = DataState(paginator)
                paginator.paging.reset()
                paginator.handler.showData?((true, .first(data)))
                paginator.handler.showEmptyProgress?(false)
            } else {
                paginator.currentState = EmptyDataState(paginator)
                paginator.handler.showEmptyProgress?(false)
                paginator.handler.showEmptyView?(true)
            }
        }

        override func fail(_ error: Error) {
            paginator.currentState = EmptyErrorState(paginator)
            paginator.handler.showEmptyProgress?(false)
            paginator.handler.showEmptyError?((true, error))
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class EmptyErrorState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showEmptyError?((false, nil))
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func refresh() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showEmptyError?((false, nil))
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class EmptyDataState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showEmptyView?(false)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func refresh() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showEmptyView?(false)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class DataState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showData?((false, .first([])))
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func refresh() {
            paginator.currentState = RefreshState(paginator)
            paginator.handler.showRefreshProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func loadNewPage() {
            paginator.currentState = PageProgressState(paginator)
            paginator.handler.showPageProgress?(true)
            paginator.loadPage(paginator.paging.next())
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class RefreshState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showData?((false, .first([])))
            paginator.handler.showRefreshProgress?(false)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func newData(_ data: [T]) {
            if !data.isEmpty {
                paginator.currentState = DataState(paginator)
                paginator.paging.reset()
                paginator.handler.showRefreshProgress?(false)
                paginator.handler.showData?((true, .first(data)))
            } else {
                paginator.currentState = EmptyDataState(paginator)
                paginator.handler.showData?((false, .first([])))
                paginator.handler.showRefreshProgress?(false)
                paginator.handler.showEmptyView?(true)
            }
        }

        override func fail(_ error: Error) {
            paginator.currentState = DataState(paginator)
            paginator.handler.showRefreshProgress?(false)
            paginator.handler.showErrorMessage?(error)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class PageProgressState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showData?((false, .first([])))
            paginator.handler.showPageProgress?(false)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func newData(_ data: [T]) {
            if !data.isEmpty {
                paginator.currentState = DataState(paginator)
                paginator.paging.turnNext()
                paginator.handler.showPageProgress?(false)
                paginator.handler.showData?((true, .next(data)))
            } else {
                paginator.currentState = AllDataState(paginator)
                paginator.handler.showPageProgress?(false)
                paginator.handler.allDataFetched?()
            }
        }

        override func refresh() {
            paginator.currentState = RefreshState(paginator)
            paginator.handler.showPageProgress?(false)
            paginator.handler.showRefreshProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func fail(_ error: Error) {
            paginator.currentState = DataState(paginator)
            paginator.handler.showPageProgress?(false)
            paginator.handler.showErrorMessage?(error)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class AllDataState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showData?((false, .first([])))
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func refresh() {
            paginator.currentState = RefreshState(paginator)
            paginator.handler.showRefreshProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func release() {
            paginator.currentState = ReleasedState(paginator)
            paginator.subscriber?.cancel()
        }
    }

    private final class ReleasedState: State<T, P> {
        override func restart() {
            paginator.currentState = EmptyProgressState(paginator)
            paginator.handler.showData?((false, .first([])))
            paginator.handler.showEmptyView?(false)
            paginator.handler.showEmptyProgress?(true)
            paginator.loadPage(paginator.paging.first)
        }

        override func refresh() {
            self.restart()
        }
    }

    private class State<ST, SP: Paging> {
        weak var paginator: Paginator<ST, SP>!
        init(_ paginator: Paginator<ST, SP>) {
            self.paginator = paginator
        }

        func restart() {}
        func refresh() {}
        func loadNewPage() {}
        func release() {}
        func newData(_ data: [ST]) {}
        func fail(_ error: Error) {}
    }

    public final class Handler<HT> {
        fileprivate var showEmptyProgress: Action<Bool>?
        fileprivate var showEmptyError: Action<(show: Bool, error: Error?)>?
        fileprivate var showEmptyView: Action<Bool>?
        fileprivate var showData: Action<(show: Bool, data: PaginatorData<HT>)>?
        fileprivate var showErrorMessage: Action<Error>?
        fileprivate var showRefreshProgress: Action<Bool>?
        fileprivate var showPageProgress: Action<Bool>?
        fileprivate var allDataFetched: ActionFunc?

        @discardableResult
        func showEmptyProgress(_ action: @escaping Action<Bool>) -> Handler<HT> {
            self.showEmptyProgress = action
            return self
        }

        @discardableResult
        func showEmptyError(_ action: @escaping Action<(show: Bool, error: Error?)>) -> Handler<HT> {
            self.showEmptyError = action
            return self
        }

        @discardableResult
        func showEmptyView(_ action: @escaping Action<Bool>) -> Handler<HT> {
            self.showEmptyView = action
            return self
        }

        @discardableResult
        func showData(_ action: @escaping Action<(show: Bool, data: PaginatorData<HT>)>) -> Handler<HT> {
            self.showData = action
            return self
        }

        @discardableResult
        func showErrorMessage(_ action: @escaping Action<Error>) -> Handler<HT> {
            self.showErrorMessage = action
            return self
        }

        @discardableResult
        func showRefreshProgress(_ action: @escaping Action<Bool>) -> Handler<HT> {
            self.showRefreshProgress = action
            return self
        }

        @discardableResult
        func showPageProgress(_ action: @escaping Action<Bool>) -> Handler<HT> {
            self.showPageProgress = action
            return self
        }

        @discardableResult
        func allDataFetched(_ action: @escaping ActionFunc) -> Handler<HT> {
            self.allDataFetched = action
            return self
        }
    }
}
