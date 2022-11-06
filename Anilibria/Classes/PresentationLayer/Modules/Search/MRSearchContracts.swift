import UIKit

// MARK: - Contracts

protocol SearchViewBehavior: AnyObject {
    func set(items: [SearchValue])
}

protocol SearchEventHandler: ViewControllerEventHandler {
    func bind(view: SearchViewBehavior, router: SearchRoutable)

    func back()
    func search(query: String)
    func select(item: SearchValue)
}
