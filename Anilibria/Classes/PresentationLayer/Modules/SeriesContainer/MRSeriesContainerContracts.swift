import UIKit

// MARK: - Contracts

protocol SeriesContainerViewBehavior: WaitingBehavior {}

protocol SeriesContainerEventHandler: ViewControllerEventHandler {
    func bind(view: SeriesContainerViewBehavior,
              router: SeriesContainerRoutable,
              series: Series)

    func share(sourceView: UIView?)
}
