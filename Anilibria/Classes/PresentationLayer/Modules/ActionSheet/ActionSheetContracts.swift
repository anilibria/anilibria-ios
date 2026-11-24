import UIKit

// MARK: - Contracts

protocol ActionSheetViewBehavior: AnyObject {
    func set(items: [ChoiceGroup])
}

protocol ActionSheetEventHandler: ViewControllerEventHandler {
    func bind(view: ActionSheetViewBehavior,
              router: ActionSheetRoutable,
              source: any ActionSheetGroupSource)
    func select(item: SheetSelector)

    func back()
}
