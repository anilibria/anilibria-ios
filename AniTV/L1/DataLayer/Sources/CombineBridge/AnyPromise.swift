//
//  AnyPromise.swift
//
//  Мост между async-кодом уровня L1 (без Combine) и Publisher'ами уровней L2/L3.
//

import Foundation
import Combine

/// Обёртка над `Task`, позволяющая запустить async-операцию и получить результат как `AnyPublisher`.
public final class AnyPromise<T, E: Error> {
    private let task: Task<T, E>

    public init(_ operation: @escaping () async throws(E) -> T) {
        self.task = Task { try await operation() }
    }

    /// Отменяет лежащую под капотом задачу.
    public func cancel() {
        task.cancel()
    }

    /// Publish-результат в указанный completion.
    public func publish(to completion: @escaping (Result<T, E>) -> Void) {
        Task {
            do {
                completion(.success(try await task.value))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Превращает промис в `AnyPublisher`.
    public func asPublisher() -> AnyPublisher<T, E> {
        Future<T, E> { [weak self] promise in
            self?.publish(to: promise)
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Error {
    /// Запускает async-функцию как Publisher (подписка выполняется сразу).
    static func create(asyncFunc: @escaping () async throws -> Output) -> AnyPublisher<Output, Failure> {
        AnyPromise(asyncFunc).asPublisher()
    }

    /// Запускает async-функцию как Publisher с возможностью отмены через returned `AnyCancellable`.
    static func cancellableCreate(asyncFunc: @escaping () async throws -> Output) -> (AnyCancellable, AnyPublisher<Output, Failure>) {
        let promise = AnyPromise(asyncFunc)
        return (AnyCancellable(promise.cancel), promise.asPublisher())
    }
}
