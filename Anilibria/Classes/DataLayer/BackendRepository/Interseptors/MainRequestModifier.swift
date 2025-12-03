//
//  MainRequestModifier.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation
import Combine

final class MainRequestModifier: AsyncRequestModifier {
    private let tokenRepository: TokenRepository

    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func modify(_ request: any BackendAPIRequest, completion: @escaping (any BackendAPIRequest) -> Void) {
        guard var result = request as? any AuthorizableAPIRequest else {
            return completion(request)
        }

        var bag: AnyCancellable?
        bag = tokenRepository.getToken().sink { token in
            if let token {
                result.headers["Authorization"] = "Bearer \(token)"
                completion(result)
            } else {
                completion(request)
            }
            bag?.cancel()
        }
    }
}
