import RxSwift

public extension PrimitiveSequenceType where Self.Trait == RxSwift.SingleTrait {
    func afterDone(_ action: @escaping ActionFunc) -> Single<Element> {
        return self.do(afterSuccess: { _ in
            action()
        }, afterError: { _ in
            action()
        })
    }

    func manageActivity(_ activity: ActivityDisposable?) -> Single<Element> {
        return self.afterDone {
            activity?.dispose()
        }
    }
}
