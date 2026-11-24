import DITranquillity
import Combine
import UIKit

final class SearchPart: DIPart {
    static func load(container: DIContainer) {
        container.register(SearchPresenter.init)
            .as(SearchEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class SearchPresenter {
    private weak var view: SearchViewBehavior!
    private var router: SearchRoutable!

    private let mainService: MainService
    private var cancellable: AnyCancellable?
    private var currentQuery: String = ""

    init(mainService: MainService) {
        self.mainService = mainService
    }
}

extension SearchPresenter: Loggable {
    var defaultLoggingTag: LogTag {
        return .presenter
    }
}

extension SearchPresenter: SearchEventHandler {
    func bind(view: SearchViewBehavior, router: SearchRoutable) {
        self.view = view
        self.router = router
    }

    func search(query: String) {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query != currentQuery else { return }
        currentQuery = query
        cancellable = nil
        view.set(items: [])
        guard !query.isEmpty else { return }
        cancellable = Just(query)
            .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .flatMap(mainService.search(query:))
            .sink(onNext: { [weak self] items in
                guard let self, self.currentQuery == query else { return }
                self.handle(items)
            }, onError: { [weak self] error in
                guard let self, self.currentQuery == query else { return }
                self.view.set(items: [])
                self.view.showSearchFailure()
                self.log(.error, error.message)
            })
    }

    func retry() {
        let query = currentQuery
        currentQuery = ""
        search(query: query)
    }

    func select(item: SearchValue) {
        router.close(selecting: item)
    }

    func back() {
        router.close(selecting: nil)
    }

    private func handle(_ items: [Series]) {
        var values: [SearchValue] = items.map {.series($0) }

        if values.isEmpty && self.currentQuery.isEmpty == false {
            if (self.router.parentRouter is CatalogRoutable) == false {
                values.append(.filter)
            }
            values.append(.google(self.currentQuery))
        }

        self.view.set(items: values)
    }
}

public struct SearchResultCommand: RouteCommand {
    let value: SearchValue
}
