import DITranquillity
import Combine
import UIKit

final class ConfigurationPart: DIPart {
    static func load(container: DIContainer) {
        container.register(ConfigurationPresenter.init)
            .as(ConfigurationEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class ConfigurationPresenter {
    private weak var view: ConfigurationViewBehavior!
    private var router: ConfigurationRoutable!

    private var bag = Set<AnyCancellable>()

    private let appService: AppConfigurationService

    init(appService: AppConfigurationService) {
        self.appService = appService
    }
}

extension ConfigurationPresenter: ConfigurationEventHandler {
    func bind(view: ConfigurationViewBehavior, router: ConfigurationRoutable) {
        self.view = view
        self.router = router
    }

    func didLoad() {
        self.appService
            .startConfiguration()
            .sink(onError: { [weak self] error in
                self?.handle(error: error)
            })
            .store(in: &bag)
    }

    private func handle(error: Error) {
        switch error {
        case AppConfigError.empty:
            self.showAlert(with: L10n.Error.configirationEmpty)
        case AppConfigError.broken:
            self.showAlert(with: L10n.Error.configirationBroken)
        case AppConfigError.notFound:
            self.showAlert(with: L10n.Error.configirationNotFound)
        default:
            self.router.show(error: error)
        }
    }

    private func showAlert(with message: String) {
        self.router.openAlert(title: L10n.Alert.Title.error,
                              message: message,
                              buttons: [L10n.Buttons.retry, L10n.Buttons.next]) { [weak self] index in
            if index == 0 {
                self?.didLoad()
            } else {
                self?.appService.manualComplete()
            }
        }
    }
}
