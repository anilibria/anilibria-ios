import IGListKit
import UIKit

// MARK: - Contracts

protocol ChoiceSheetViewBehavior: class {
    func set(items: [ListDiffable])
}

protocol ChoiceSheetEventHandler: ViewControllerEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceItem])

    func back()
    func select(item: ChoiceItem)
}
