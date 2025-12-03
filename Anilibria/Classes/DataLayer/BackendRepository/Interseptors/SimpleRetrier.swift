//
//  SimpleRetrier.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

struct SimpleRetrier: LoadRetrier {

    private let handler: (Error, Int, @escaping RetryCompletion) -> Void

    init(_ handler: @escaping (Error, Int, @escaping RetryCompletion) -> Void) {
        self.handler = handler
    }


    func need(
        retry request: any BackendAPIRequest,
        error: any Error,
        retryNumber: Int,
        completion: @escaping RetryCompletion
    ) {
        handler(error, retryNumber, completion)
    }
}
