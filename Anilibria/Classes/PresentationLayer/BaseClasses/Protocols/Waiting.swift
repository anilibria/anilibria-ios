import UIKit

public protocol WaitingBehavior: class {
    var isLoading: Bool { get }
    func showLoading(fullscreen: Bool) -> ActivityDisposable?
}

extension WaitingBehavior where Self: UIViewController {
    public var isLoading: Bool {
        return MRLoaderManager.isLoading()
    }

    public func showLoading(fullscreen: Bool) -> ActivityDisposable? {
        var target: UIViewController?
        if !fullscreen {
            target = self
        }
        return MRLoaderManager.show(with: target)
    }
}
