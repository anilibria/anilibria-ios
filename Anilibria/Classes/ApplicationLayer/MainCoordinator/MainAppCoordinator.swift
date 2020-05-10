import DITranquillity
import Foundation
import Kingfisher
import RxSwift
import UIKit

public class MainAppCoordinator: Loggable {
    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    public static let shared: MainAppCoordinator = {
        let dependencyConfiguration = DependenciesConfigurationBase()
        let coordinator = MainAppCoordinator(configuration: dependencyConfiguration)
        return coordinator
    }()

    private var configuration: DependenciesConfiguration
    public var container: DIContainer

    private let router: AppRouter
    private let appService: AppConfigurationService
    private var bag: DisposeBag = DisposeBag()

    init(configuration: DependenciesConfiguration) {
        self.configuration = configuration
        self.configuration.setup()
        self.container = self.configuration.configuredContainer()
        self.router = AppRouter()
        self.appService = self.container.resolve()

        self.log(.debug, "Dependencies are configured")
    }

    func start() {
        MainTheme.shared.apply()
        self.log(.debug, "App coordinator started")
        self.openMainModule()
    }

    // MARK: - Modules routing

    private func openMainModule() {
        self.appService.fetchState()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .started:
                    self?.router.openLoadingScene()
                case .completed:
                    self?.router.openDefaultScene()
                }
            })
            .disposed(by: self.bag)
    }
}
