import UIKit

final class ScheduleAssembly {
    class func createModule(schedules: [Schedule],
                            parent: Router? = nil) -> ScheduleViewController {
        let module = ScheduleViewController()
        let router = ScheduleRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module,
                            router: router,
                            schedules: schedules)
        return module
    }
}

// MARK: - Route

protocol ScheduleRoute {
    func open(schedules: [Schedule])
}

extension ScheduleRoute where Self: RouterProtocol {
    func open(schedules: [Schedule]) {
        let module = ScheduleAssembly.createModule(schedules: schedules,
                                                   parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
