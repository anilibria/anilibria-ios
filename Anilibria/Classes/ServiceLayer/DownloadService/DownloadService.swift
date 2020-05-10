import DITranquillity
import Foundation
import RxCocoa
import RxSwift

final class DownloadServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(DownloadServiceImp.init)
            .as(DownloadService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol DownloadService {
    func download(torrent: Torrent, fileName: String) -> Single<Void>
}

final class DownloadServiceImp: DownloadService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
    }

    func download(torrent: Torrent, fileName: String) -> Single<Void> {
        return Single.deferred {
            guard let url = torrent.url else {
                return .error(AppError.server(message: L10n.Error.authorizationFailed))
            }
            let data = try Data(contentsOf: url)
            return .just(data)
        }
        .flatMap { [unowned self] in self.save(data: $0, name: fileName)}
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func save(data: Data, name: String) -> Single<Void> {
        return Single.deferred { [unowned self] in
            let directory = try self.getDirectoryUrl()
            try self.save(data: data,
                          to: directory,
                          with: name)
            return .just(())

        }
        .subscribeOn(self.schedulers.background)
        .observeOn(self.schedulers.main)
    }

    private func getDirectoryUrl() throws -> URL {
        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let anilibriaFolder = directory.appendingPathComponent(Constants.downloadFolder)
        if FileManager.default.fileExists(atPath: anilibriaFolder.absoluteString) {
            return anilibriaFolder
        }

        try FileManager.default.createDirectory(at: anilibriaFolder, withIntermediateDirectories: true, attributes: nil)
        return anilibriaFolder
    }

    private func save(data: Data, to directory: URL, with name: String, index: Int? = nil) throws {
        var fileName = name
        if let value = index {
            fileName = "\(fileName) (\(value))"
        }
        let fileURL = directory.appendingPathComponent("\(fileName).torrent")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try self.save(data: data,
                                 to: directory,
                                 with: name,
                                 index: (index ?? 0) + 1)
        }
        try data.write(to: fileURL, options: .withoutOverwriting)
    }

}
