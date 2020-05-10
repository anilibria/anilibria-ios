import DITranquillity
import UIKit

final class FilterPart: DIPart {
    static func load(container: DIContainer) {
        container.register(FilterPresenter.init)
            .as(FilterEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

public struct FilterRouteCommand: RouteCommand {
    let value: SeriesFilter
}

final class FilterPresenter {
    private weak var view: FilterViewBehavior!
    private var router: FilterRoutable!
    private var filter: SeriesFilter!
    private var data: FilterData!
}

extension FilterPresenter: FilterEventHandler {
    func bind(view: FilterViewBehavior,
              router: FilterRoutable,
              filter: SeriesFilter,
              data: FilterData) {
        self.view = view
        self.router = router
        self.filter = filter
        self.data = data
    }

    func didLoad() {
        self.configure()
    }

    func apply() {
        let command = FilterRouteCommand(value: self.filter)
        self.router.execute(command)
        self.back()
    }

    func reset() {
        self.filter = SeriesFilter()
        self.configure()
    }

    func change(filter: SeriesFilter) {
        self.filter.sorting = filter.sorting
        self.filter.isCompleted = filter.isCompleted
    }

    func back() {
        self.router.back()
    }

    private func configure() {
        var items: [NSObject] = [
            FilterHeaderItem(self.filter),
            self.generateSeasonsTags()
        ]

        if let years = self.generateYearsTags() {
            items.append(years)
        }

        if let genres = self.generateGenresTags() {
            items.append(genres)
        }

        self.view.set(items: items)
    }

    private func generateSeasonsTags() -> FilterTagsItem {
        let changed: Action<Selectable<String>> = { [weak self] param in
            param.isSelected.toggle()
            if param.isSelected {
                self?.filter.seasons.insert(param.value)
            } else {
                self?.filter.seasons.remove(param.value)
            }
        }

        let seasons = self.data.seasons.map { value -> Selectable<String> in
            let item = Selectable(value)
            item.isSelected = self.filter.seasons.contains(value)
            return item
        }

        return FilterTagsItem(title: L10n.Screen.Filter.seasons,
                              items: seasons,
                              changed: changed)
    }

    private func generateYearsTags() -> FilterTagsItem? {
        if self.data.years.isEmpty == false {
            let changed: Action<Selectable<String>> = { [weak self] param in
                param.isSelected.toggle()
                if param.isSelected {
                    self?.filter.years.insert(param.value)
                } else {
                    self?.filter.years.remove(param.value)
                }
            }

            let years = self.data.years.map { value -> Selectable<String> in
                let item = Selectable(value)
                item.isSelected = self.filter.years.contains(value)
                return item
            }

            return FilterTagsItem(title: L10n.Screen.Filter.years,
                                  items: years,
                                  changed: changed)
        }

        return nil
    }

    private func generateGenresTags() -> FilterTagsItem? {
        if self.data.genres.isEmpty == false {
            let changed: Action<Selectable<String>> = { [weak self] param in
                param.isSelected.toggle()
                if param.isSelected {
                    self?.filter.genres.insert(param.value)
                } else {
                    self?.filter.genres.remove(param.value)
                }
            }

            let genres = self.data.genres.map { value -> Selectable<String> in
                let item = Selectable(value)
                item.isSelected = self.filter.genres.contains(value)
                return item
            }

            return FilterTagsItem(title: L10n.Screen.Filter.genres,
                                  items: genres,
                                  changed: changed)
        }

        return nil
    }
}
