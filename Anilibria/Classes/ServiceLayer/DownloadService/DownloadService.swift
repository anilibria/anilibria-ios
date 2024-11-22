import DITranquillity
import Foundation
import Combine

final class DownloadServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(DownloadServiceImp.init)
            .as(DownloadService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol DownloadService {
    func download(torrent: Torrent, fileName: String) -> AnyPublisher<Void, Error>
}

final class DownloadServiceImp: DownloadService {
    let backendRepository: BackendRepository

    init(backendRepository: BackendRepository) {
        self.backendRepository = backendRepository
    }

    func download(torrent: Torrent, fileName: String) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            let request = GetTorrentRequest(id: torrent.id)
            return self.backendRepository
                .request(request)
        }
        .flatMap { [unowned self] in self.save(data: $0, name: fileName)}
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func save(data: Data, name: String) -> AnyPublisher<Void, Error> {
        return Deferred { [unowned self] in
            do {
                let directory = try self.getDirectoryUrl()
                try self.save(data: data,
                              to: directory,
                              with: name)
            } catch {
                return AnyPublisher<Void, Error>.fail(error)
            }

            return AnyPublisher<Void, Error>.just(())
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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
