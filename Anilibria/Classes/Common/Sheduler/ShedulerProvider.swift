import Foundation
import RxSwift

public protocol SchedulerProvider {
    var background: SchedulerType { get }
    var main: SchedulerType { get }
    func newThread(_ name: String) -> SchedulerType
}

public final class SchedulerProviderImp: SchedulerProvider {
    public lazy var background: SchedulerType = ConcurrentDispatchQueueScheduler(queue: .global())
    public lazy var main: SchedulerType = MainScheduler.instance

    public func newThread(_ name: String) -> SchedulerType {
        return ConcurrentDispatchQueueScheduler(queue: .init(label: name, qos: .background))
    }
}
