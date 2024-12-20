//
//  KeychainManager.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


import UIKit
import Security
import Combine

final class KeychainManager {
    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
    }

    func save<T: Codable>(key: String, item: T) throws {
        try? remove(key: key)
        let data = try JSONEncoder().encode(item)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }

    private func searchQuery(for key: String) -> [String: Any] {[
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key
    ]}

    func get<T: Codable>(key: String) -> AnyPublisher<T?, Never> {
        return Deferred { [weak self] () -> AnyPublisher<T?, Never> in
            if UIApplication.shared.isProtectedDataAvailable {
                return .just(self?.getValue(key: key))
            }
            return NotificationCenter.default
                .publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
                .first()
                .map { _ in self?.getValue(key: key) }
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func getValue<T: Codable>(key: String) -> T?  {
        var query = searchQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }

    func remove(key: String) throws {
        let query = searchQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
