//
//  NetworkProtocols.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Foundation

protocol LoadRetrier {
    typealias RetryCompletion = (Bool) -> Void
    func need(retry request: any BackendAPIRequest,
              baseURL: URL?,
              error: Error,
              retryNumber: Int,
              completion: @escaping RetryCompletion)
}

protocol AsyncRequestModifier {
    func modify(_ request: any BackendAPIRequest, completion: @escaping (any BackendAPIRequest) -> Void)
}

protocol RequestModifier: AsyncRequestModifier {
    func modify(_ request: any BackendAPIRequest) -> any BackendAPIRequest
}

extension RequestModifier {
    func modify(_ request: any BackendAPIRequest, completion: @escaping (any BackendAPIRequest) -> Void) {
        completion(modify(request))
    }
}
