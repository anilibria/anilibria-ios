import UIKit

// MARK: - Contracts

protocol ChoiceSheetViewBehavior: AnyObject {
    func set(items: [ChoiceItem])
}

protocol ChoiceSheetEventHandler: ViewControllerEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceItem])
    func select(item: ChoiceItem)

    func back()
}
