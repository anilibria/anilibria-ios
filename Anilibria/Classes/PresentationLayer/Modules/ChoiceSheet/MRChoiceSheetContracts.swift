import UIKit

// MARK: - Contracts

protocol ChoiceSheetViewBehavior: AnyObject {
    func set(items: [ChoiceGroup])
}

protocol ChoiceSheetEventHandler: ViewControllerEventHandler {
    func bind(view: ChoiceSheetViewBehavior,
              router: ChoiceSheetRoutable,
              items: [ChoiceGroup])

    func back()
}
