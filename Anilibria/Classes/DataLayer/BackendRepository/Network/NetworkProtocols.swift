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
    func need(retry request: URLRequest,
              error: Error,
              retryNumber: Int,
              completion: @escaping RetryCompletion)
}

protocol AsyncRequestModifier {
    func modify(_ urlRequest: URLRequest, completion: @escaping (URLRequest) -> Void)
}

protocol RequestModifier: AsyncRequestModifier {
    func modify(_ urlRequest: URLRequest) -> URLRequest
}

extension RequestModifier {
    func modify(_ urlRequest: URLRequest, completion: @escaping (URLRequest) -> Void) {
        completion(modify(urlRequest))
    }
}
