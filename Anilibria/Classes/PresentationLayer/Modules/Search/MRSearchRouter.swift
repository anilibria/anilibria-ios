import UIKit

protocol SearchRoutable: BaseRoutable {
    func close(selecting result: SearchValue?)
}

final class SearchRouter: BaseRouter, SearchRoutable {
    func close(selecting result: SearchValue?) {
        controller.navigationController?.dismiss(animated: true) { [parentRouter] in
            if let result {
                parentRouter?.execute(SearchResultCommand(value: result))
            }
        }
    }
}
