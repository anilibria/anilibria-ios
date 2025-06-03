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
    let value: SeriesSearchData.Filter
}

final class FilterPresenter {
    private weak var view: FilterViewBehavior!
    private var router: FilterRoutable!
    private var filter: SeriesSearchData.Filter!
    private var data: FilterData!
}

extension FilterPresenter: FilterEventHandler {
    func bind(view: FilterViewBehavior,
              router: FilterRoutable,
              filter: SeriesSearchData.Filter,
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
        self.filter = SeriesSearchData.Filter()
        self.configure()
    }

    func back() {
        self.router.back()
    }

    private func configure() {
        var results: [FilterTagsItem] = []

        if let items = getYears() {
            results.append(items)
        }

        if let items = generatePublishStatuses() {
            results.append(items)
        }

        if let items = generateProductionStatuses() {
            results.append(items)
        }

        if let items = generateAgeRatings() {
            results.append(items)
        }

        if let items = generateReleaseTypes() {
            results.append(items)
        }

        if let items = generateSeasons() {
            results.append(items)
        }

        if let items = self.generateGenres() {
            results.append(items)
        }

        let sorting = getSorting()
        let yearsRange = getYearsRange()

        self.view.set(sorting: sorting,
                      years: yearsRange,
                      items: results)
    }

    private func generateSeasons() -> FilterTagsItem? {
        if data.seasons.isEmpty {
            return nil
        }

        let results = data.seasons.map { item in
            let item = FilterTagData(
                value: item.value,
                displayValue: item.description,
                selected: filter.seasons.contains(item.value),
                select: { [weak self] in self?.filter.seasons.insert($0) },
                deselect: { [weak self] in self?.filter.seasons.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.seasons,
            items: results
        )
    }


    private func generateGenres() -> FilterTagsItem? {
        if data.genres.isEmpty {
            return nil
        }

        let results = data.genres.map { item in
            let item = FilterTagData(
                value: item.id,
                displayValue: item.name,
                selected: filter.genres.contains(item.id),
                select: { [weak self] in self?.filter.genres.insert($0) },
                deselect: { [weak self] in self?.filter.genres.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.genres,
            items: results
        )
    }

    private func generateReleaseTypes() -> FilterTagsItem? {
        if data.releaseTypes.isEmpty {
            return nil
        }

        let results = data.releaseTypes.map { item in
            let item = FilterTagData(
                value: item.value,
                displayValue: item.description,
                selected: filter.types.contains(item.value),
                select: { [weak self] in self?.filter.types.insert($0) },
                deselect: { [weak self] in self?.filter.types.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.types,
            items: results
        )
    }

    private func generateProductionStatuses() -> FilterTagsItem? {
        if data.productionStatuses.isEmpty {
            return nil
        }

        let results = data.productionStatuses.map { item in
            let item = FilterTagData(
                value: item.value,
                displayValue: item.description,
                selected: filter.productionStatuses.contains(item.value),
                select: { [weak self] in self?.filter.productionStatuses.insert($0) },
                deselect: { [weak self] in self?.filter.productionStatuses.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.productionStatuses,
            items: results
        )
    }

    private func generatePublishStatuses() -> FilterTagsItem? {
        if data.publishStatuses.isEmpty {
            return nil
        }

        let results = data.publishStatuses.map { item in
            let item = FilterTagData(
                value: item.value,
                displayValue: item.description,
                selected: filter.publishStatuses.contains(item.value),
                select: { [weak self] in self?.filter.publishStatuses.insert($0) },
                deselect: { [weak self] in self?.filter.publishStatuses.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.publishStatuses,
            items: results
        )
    }

    private func generateAgeRatings() -> FilterTagsItem? {
        if data.ageRatings.isEmpty {
            return nil
        }
        
        let results = data.ageRatings.map { item in
            let item = FilterTagData(
                value: item.value,
                displayValue: item.label,
                selected: filter.ageRatings.contains(item.value),
                select: { [weak self] in self?.filter.ageRatings.insert($0) },
                deselect: { [weak self] in self?.filter.ageRatings.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.ageRatings,
            items: results
        )
    }

    private func getSorting() -> FilterSingleItem? {
        if data.sortings.isEmpty {
            return nil
        }

        let selectedItem = data.sortings.first(where: { $0.id == filter.sorting })

        return FilterSingleItem(
            title: L10n.Screen.Filter.sotring,
            value: selectedItem?.name ?? L10n.Common.default,
            selected: selectedItem != nil
        ) { [weak self] item in
            self?.selectSorting(sorting: item)
        }
    }

    private func selectSorting(sorting: FilterSingleItem) {
        let didSelect: (Sorting?) -> Bool = { [weak self] item in
            self?.filter.sorting = item?.id
            sorting.isSelected = item != nil
            sorting.value = item?.name ?? L10n.Common.default
            return true
        }

        let simple = ChoiceItem(
            value: nil,
            title: L10n.Common.default,
            isSelected: filter.sorting == nil,
            didSelect: didSelect
        )

        let items = data.sortings.map { item in
            ChoiceItem(
                value: item,
                title: item.name,
                isSelected: item.id == filter.sorting,
                didSelect: didSelect
            )
        }

        router.openSheet(with: [ChoiceGroup(items: [simple] + items)])
    }

    private func getYears() -> FilterTagsItem? {
        if data.years.isEmpty {
            return nil
        }

        let results = data.years.map { item in
            let item = FilterTagData(
                value: item,
                displayValue: "\(item)",
                selected: filter.years.contains(item),
                select: { [weak self] in self?.filter.years.insert($0) },
                deselect: { [weak self] in self?.filter.years.remove($0) }
            )
            return item
        }

        return FilterTagsItem(
            title: L10n.Screen.Filter.years,
            items: results
        )
    }

    private func getYearsRange() -> FilterRangeItem? {
        if data.yearsRange.count <= 1 {
            return nil
        }

        let minIndex = (filter.yearsRange?.fromYear).flatMap { data.yearsRange.firstIndex(of: $0) }
        let maxIndex = (filter.yearsRange?.toYear).flatMap { data.yearsRange.firstIndex(of: $0) }

        let count = data.yearsRange.count
        return FilterRangeItem(
            title: L10n.Screen.Filter.years,
            itemsCount: count,
            selectedMinIndex: minIndex,
            selectedMaxIndex: maxIndex,
            displayValueFormatter: { [weak self] item in
                guard let self else { return "" }
                let min = item.selectedMinIndex ?? 0
                let max = item.selectedMaxIndex ?? count - 1
                let fromYear = data.yearsRange[min]
                let toYear = data.yearsRange[max]
                return "\(fromYear) - \(toYear)"
            },
            updateRange: { [weak self] item in
                guard
                    let self,
                    let min = item.selectedMinIndex,
                    let max = item.selectedMaxIndex
                else { return }
                filter.yearsRange = .init(
                    fromYear: data.yearsRange[min],
                    toYear: data.yearsRange[max]
                )
            }
        )
    }
}
