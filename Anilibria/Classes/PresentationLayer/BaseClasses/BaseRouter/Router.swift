import UIKit

protocol RouteCommand {}

protocol RouterCommandResponder: class {
    func respond(command: RouteCommand) -> Bool
}

protocol Router: class {
    var parentRouter: Router? { get }
    var responder: RouterCommandResponder? { get set }
    func execute(_ command: RouteCommand)
}

protocol RouterProtocol: Router {
    var controller: UIViewController! { get }
}

protocol BaseRoutable: RouterProtocol, ErrorHandlingRoute {}

class BaseRouter: BaseRoutable {
    weak var controller: UIViewController!
    weak var responder: RouterCommandResponder?

    private(set) weak var parentRouter: Router?

    init(view: UIViewController, parent: Router? = nil) {
        self.controller = view
        self.parentRouter = parent
    }

    func execute(_ command: RouteCommand) {
        if self.responder?.respond(command: command) == true {
            return
        }
        self.parentRouter?.execute(command)
    }
}
