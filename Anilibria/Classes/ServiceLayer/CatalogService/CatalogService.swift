//
//  CatalogService.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import DITranquillity
import Foundation
import Combine

final class CatalogServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(CatalogServiceImp.init)
            .as(CatalogService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol CatalogService {
    func fetchSeries(id: Int) -> AnyPublisher<Series, Error>
    func fetchSeries(alias: String) -> AnyPublisher<Series, Error>
    func fetchCatalog(page: Int, filter: SeriesFilter) -> AnyPublisher<[Series], Error>
    func fetchFilterData() -> AnyPublisher<FilterData, Error>
}

final class CatalogServiceImp: CatalogService {
    let backendRepository: BackendRepository

    private var filterData: FilterData?

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func fetchSeries(id: Int) -> AnyPublisher<Series, Error> {
        fetchSeries(request: .init(id: id))
    }

    func fetchSeries(alias: String) -> AnyPublisher<Series, Error> {
        fetchSeries(request: .init(alias: alias))
    }

    private func fetchSeries(request: SeriesRequest) -> AnyPublisher<Series, Error> {
        return Deferred { [unowned self] in
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchCatalog(page: Int, filter: SeriesFilter) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = CatalogRequest(filter: filter, page: page)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func search(query: String) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = SearchRequest(query: query)
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFilterData() -> AnyPublisher<FilterData, Error> {
        return Deferred { [unowned self] in
            if let data = self.filterData {
                return AnyPublisher<FilterData, Error>.just(data)
            }
            return self.fetchAgeRatings()
                .zip(self.fetchGenres(), { ages, genres in
                    var data = FilterData()
                    data.ageRatings = ages
                    data.genres = genres
                    return data
                })
                .zip(self.fetchProductionStatuses(), { data, value in
                    var result = data
                    result.productionStatuses = value
                    return result
                })
                .zip(self.fetchPublishStatuses(), { data, value in
                    var result = data
                    result.publishStatuses = value
                    return result
                })
                .zip(self.fetchSeasons(), { data, value in
                    var result = data
                    result.seasons = value
                    return result
                })
                .zip(self.fetchSortings(), { data, value in
                    var result = data
                    result.sortings = value
                    return result
                })
                .zip(self.fetchReleaseTypes(), { data, value in
                    var result = data
                    result.releaseTypes = value
                    return result
                })
                .zip(self.fetchYears(), { data, value in
                    var result = data
                    result.years = value
                    return result
                })
                .do(onNext: { [weak self] in
                    self?.filterData = $0
                })
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchAgeRatings() -> AnyPublisher<[AgeRating], Error> {
        return Deferred { [unowned self] in
            let request = AgeRatingsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchProductionStatuses() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = ProductionStatusesRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchPublishStatuses() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = PublishStatusesRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchReleaseTypes() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = ReleaseTypesRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchSeasons() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = SeasonsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchSortings() -> AnyPublisher<[Sorting], Error> {
        return Deferred { [unowned self] in
            let request = SortingRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchGenres() -> AnyPublisher<[Genre], Error> {
        return Deferred { [unowned self] in
            let request = GenresRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchYears() -> AnyPublisher<[Int], Error> {
        return Deferred { [unowned self] in
            let request = YearsRequest()
            return self.backendRepository
                .request(request)
                .map { $0.sorted(by: <) }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
