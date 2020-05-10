import Foundation
import RxSwift

public extension ObservableType {
    func asVoidSingle() -> Single<Void> {
        return asSingle().flatMap { _ in
            Single.just(())
        }
    }
}

public extension PrimitiveSequenceType where Self.Trait == RxSwift.SingleTrait {
    func asVoid() -> Single<Void> {
        return flatMap { _ in
            Single.just(())
        }
    }
}
