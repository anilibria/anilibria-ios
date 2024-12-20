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

    func modify(_ urlRequest: URLRequest, completion: @escaping (URLRequest) -> Void) {
        var bag: AnyCancellable?
        bag = tokenRepository.getToken().sink { token in
            if let token {
                var result = urlRequest
                result.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                completion(result)
            } else {
                completion(urlRequest)
            }
            bag?.cancel()
        }
    }
}
