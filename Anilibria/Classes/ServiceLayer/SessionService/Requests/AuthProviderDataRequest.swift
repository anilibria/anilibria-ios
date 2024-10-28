//
//  AuthProviderDataRequest.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import Foundation

public struct AuthProviderDataRequest: BackendAPIRequest {
    typealias ResponseObject = AuthProviderData
    
    let endpoint: String
    let method: NetworkManager.Method = .GET

    init(provider: AuthProvider) {
        endpoint = "/accounts/users/auth/social/\(provider.rawValue)/login"
    }
}
