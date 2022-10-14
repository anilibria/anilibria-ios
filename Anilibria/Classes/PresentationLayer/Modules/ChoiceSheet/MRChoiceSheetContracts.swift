import IGListKit
import UIKit

// MARK: - Contracts

protocol ChoiceSheetViewBehavior: AnyObject {
    func set(items: [ListDiffable])
}

protocol ChoiceSheetEventHandler: ViewControllerEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceItem])

    func back()
    func select(item: ChoiceItem)
}
