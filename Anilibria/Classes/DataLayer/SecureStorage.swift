//
//  SecureStorage.swift
//  Anilibria
//
//  Created by Ivan Morozov on 02.09.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import DITranquillity
import UIKit
import Combine
import Security
import CryptoKit

protocol SecureStorage {
    func save<T: Codable>(key: String, item: T) throws
    func get<T: Codable>(key: String) -> AnyPublisher<T?, Never>
    func remove(key: String) throws
}

final class SecureStoragePart: DIPart {
    static func load(container: DIContainer) {
#if targetEnvironment(macCatalyst)
        container.register(CryptoManager.init)
            .as(SecureStorage.self)
            .lifetime(.single)
#else
        container.register(KeychainManager.init)
            .as(SecureStorage.self)
            .lifetime(.single)
#endif
    }
}

#if targetEnvironment(macCatalyst)
final class CryptoManager: SecureStorage {
    enum CryptoError: Error {
        case unhandledError
    }

    private let keyData: SymmetricKey? = (UIDevice.current.identifierForVendor?
        .uuidString
        .data(using: .utf8)?
        .prefix(32))
        .map { SymmetricKey(data: $0) }


    func save<T: Codable>(key: String, item: T) throws {
        try? remove(key: key)
        let data = try JSONEncoder().encode(item)
        UserDefaults.standard[key] = try encrypt(input: data)
    }

    func get<T>(key: String) -> AnyPublisher<T?, Never> where T : Decodable, T : Encodable {
        return Deferred { [weak self] () -> AnyPublisher<T?, Never> in
            guard
                let data: Data = UserDefaults.standard[key],
                let decrypted = try? self?.decrypt(input: data),
                let decoded = try? JSONDecoder().decode(T.self, from: decrypted)
            else {
                return .just(nil)
            }
            return .just(decoded)
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func remove(key: String) throws {
        UserDefaults.standard[key] = nil
    }

    private func encrypt(input: Data) throws -> Data? {
        guard let keyData else {
            throw CryptoError.unhandledError
        }
        let sealed = try AES.GCM.seal(input, using: keyData)
        return sealed.combined
    }

    private func decrypt(input: Data) throws -> Data {
        guard let keyData else {
            throw CryptoError.unhandledError
        }
        let box = try AES.GCM.SealedBox(combined: input)
        let opened = try AES.GCM.open(box, using: keyData)
        return opened
    }
}

#else
final class KeychainManager: SecureStorage {
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
#endif
