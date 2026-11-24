//
//  ImageRequestModifier.swift
//  Anilibria
//
//  Created by Ivan Morozov on 25.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import Kingfisher
import Foundation
import Combine

final class ImageRequestModifier: AsyncImageDownloadRequestModifier {
    var onDownloadTaskStarted: ((Kingfisher.DownloadTask?) -> Void)?

    private var cancellabes = Set<AnyCancellable>()

    private let appConfig: AppConfigurationRepository

    init(appConfig: AppConfigurationRepository) {
        self.appConfig = appConfig
    }

    func modified(for request: URLRequest, reportModified: @escaping (URLRequest?) -> Void) {
        guard
            var urlString = request.url?.absoluteString,
            urlString.hasPrefix(URLConverter.base)
        else {
            reportModified(request)
            return
        }

        appConfig.fetchBaseImageUrl().sink(
            onNext: { url in
                let range = urlString.startIndex..<URLConverter.base.endIndex
                urlString.replaceSubrange(range, with: url.absoluteString)
                if let url = URL(string: urlString) {
                    reportModified(URLRequest(url: url))
                } else {
                    reportModified(request)
                }
            },
            onError: { _ in
                reportModified(request)
            }
        ).store(in: &cancellabes)
    }
}
