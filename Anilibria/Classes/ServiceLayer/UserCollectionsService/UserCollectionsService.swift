//
//  UserCollectionsService.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.05.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import Combine
import Foundation

final class UserCollectionsServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(UserCollectionsServiceImp.init)
            .as(UserCollectionsService.self)
            .lifetime(.single)
    }
}

enum UserCollectionsUpdates {
    case added(Series, to: UserCollectionType, from: UserCollectionType?)
    case deleted(Series, type: UserCollectionType)
}

protocol UserCollectionsService: AnyObject {
    func collectionsUpdates() -> AnyPublisher<UserCollectionsUpdates, Never>
    func fetchSeries(type: UserCollectionType, limit: Int, page: Int, data: SeriesSearchData) -> AnyPublisher<[Series], Error>
    func move(series: Series, from: UserCollectionType?, to: UserCollectionType) -> AnyPublisher<Void, Error>
    func removeFrom(collection: UserCollectionType, series: Series) -> AnyPublisher<Void, Error>
    func getCollection(for seriesID: Int) -> AnyPublisher<UserCollectionType?, Error>
    func fetchFilterData() -> AnyPublisher<FilterData, Error>
}

final class UserCollectionsServiceImp: UserCollectionsService {
    let backendRepository: BackendRepository
    private var collectionsMetadataTime: Date?
    private var collectionsMetadata: [Int: UserCollectionType] = [:]
    private let updates = PassthroughSubject<UserCollectionsUpdates, Never>()

    private var bag = Set<AnyCancellable>()

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func collectionsUpdates() -> AnyPublisher<UserCollectionsUpdates, Never> {
        updates
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func getCollection(for seriesID: Int) -> AnyPublisher<UserCollectionType?, Error> {
        if let collectionsMetadataTime, Date().distance(to: collectionsMetadataTime) > 60 * 60  {
            return .just(collectionsMetadata[seriesID])
        }

        return Deferred { [unowned self] in
            let request = GetUserCollectionDataRequest()
            return self.backendRepository
                .request(request)
        }
        .receive(on: DispatchQueue.main)
        .map { [unowned self] in
            self.collectionsMetadata.removeAll()
            $0.forEach { data in
                self.collectionsMetadata[data.seriesID] = data.collectionType
            }
            self.collectionsMetadataTime = Date()
            return collectionsMetadata[seriesID]
        }
        .eraseToAnyPublisher()
    }

    func fetchSeries(type: UserCollectionType, limit: Int, page: Int, data: SeriesSearchData) -> AnyPublisher<[Series], Error> {
        return Deferred { [unowned self] in
            let request = UserCollectionListRequest(type: type, data: data, page: page, limit: limit)
            return self.backendRepository
                .request(request)
                .map { $0.items }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func move(series: Series, from: UserCollectionType?, to: UserCollectionType) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = ChangeUserCollectionRequest(id: series.id, type: to)
            return self.backendRepository
                .request(request)
                .map { _ in
                    self.collectionsMetadata[series.id] = to
                    self.updates.send(.added(series, to: to, from: from))
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func removeFrom(collection: UserCollectionType, series: Series) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = ChangeUserCollectionRequest(id: series.id, type: nil)
            return self.backendRepository
                .request(request)
                .map { _ in
                    self.collectionsMetadata[series.id] = nil
                    self.updates.send(.deleted(series, type: collection))
                }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchFilterData() -> AnyPublisher<FilterData, Error> {
        return Deferred { [unowned self] in
            return self.fetchAgeRatings()
                .zip(self.fetchGenres(), { ages, genres in
                    var data = FilterData()
                    data.ageRatings = ages
                    data.genres = genres
                    return data
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
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchAgeRatings() -> AnyPublisher<[AgeRating], Error> {
        return Deferred { [unowned self] in
            let request = CollectionsFilterAgeRatingsRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchReleaseTypes() -> AnyPublisher<[DescribedValue<String>], Error> {
        return Deferred { [unowned self] in
            let request = CollectionsFilterReleaseTypesRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchGenres() -> AnyPublisher<[Genre], Error> {
        return Deferred { [unowned self] in
            let request = CollectionsFilterGenresRequest()
            return self.backendRepository
                .request(request)
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchYears() -> AnyPublisher<[Int], Error> {
        return Deferred { [unowned self] in
            let request = CollectionsFilterYearsRequest()
            return self.backendRepository
                .request(request)
                .map { $0.sorted(by: <) }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
