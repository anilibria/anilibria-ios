import UIKit

final class ScheduleAssembly {
    class func createModule(parent: Router? = nil) -> ScheduleViewController {
        let module = ScheduleViewController()
        let router = ScheduleRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module,
                            router: router)
        return module
    }
}

// MARK: - Route

protocol ScheduleRoute {
    func openWeekSchedule()
}

extension ScheduleRoute where Self: RouterProtocol {
    func openWeekSchedule() {
        let module = ScheduleAssembly.createModule(parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
