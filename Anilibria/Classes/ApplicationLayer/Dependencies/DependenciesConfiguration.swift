import DITranquillity
import Kingfisher
import UIKit
#if targetEnvironment(macCatalyst)
#else
import AppMetricaCore
#endif

public protocol DependenciesConfiguration: AnyObject {
    func setup()
    func configuredContainer() -> DIContainer
}

public class DependenciesConfigurationBase: DependenciesConfiguration, Loggable {
    init() {}

    // MARK: - Configure

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    public func configuredContainer() -> DIContainer {
        let container = DIContainer()
        container.append(framework: AppFramework.self)
        return container
    }

    // MARK: - Setup

    public func setup() {
        self.setupMetrica()
        self.setupLoader()
        self.setupModulesDependencies()
    }

    private func setupMetrica() {
        #if targetEnvironment(macCatalyst)
        #else
        if let config = AppMetricaConfiguration(apiKey: Keys.yandexMetricaApiKey) {
            AppMetrica.activate(with: config)
        }
        #endif
    }

    private func setupModulesDependencies() {
        // logger
        let logger = Logger()
        let swiftyLogger = SimpleLogger()
        logger.setupLogger(swiftyLogger)
        Logger.setSharedInstance(logger)
    }

    private func setupLoader() {
        MRLoaderManager.configure(with: MRLoaderView.self)
    }
}
