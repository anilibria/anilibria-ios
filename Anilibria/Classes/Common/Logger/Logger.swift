import Foundation

public enum LogTag: String {
    case unnamed
    case observable
    case model
    case viewModel
    case view
    case service
    case repository
    case presenter
}

public enum LogLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

public protocol Loggable {
    var defaultLoggingTag: LogTag { get }

    func log(_ level: LogLevel, _ message: String)
    func log(_ level: LogLevel, tag: LogTag, _ message: String)
}

public extension Loggable {
    func log(_ level: LogLevel, _ message: String) {
        self.log(level, tag: defaultLoggingTag, message)
    }

    func log(_ level: LogLevel, tag: LogTag, _ message: String) {
        Logger.sharedInstance.log(level, tag: tag, className: String(describing: type(of: self)), message)
    }
}

protocol LoggerType {
    func log(_ level: LogLevel, tag: LogTag, className: String, _ message: String)
}

final class Logger {
    internal var activeLogger: LoggerType?
    internal var disabledSymbols = Set<String>()
    fileprivate(set) static var sharedInstance = Logger()

    /// Overrides shared instance, useful for testing
    static func setSharedInstance(_ logger: Logger) {
        self.sharedInstance = logger
    }

    func setupLogger(_ logger: LoggerType) {
        assert(self.activeLogger == nil, "Changing logger is disallowed to maintain consistency")
        self.activeLogger = logger
    }

    func ignoreClass(_ type: AnyClass) {
        self.disabledSymbols.insert(String(describing: type))
    }

    func ignoreTag(_ tag: LogTag) {
        self.disabledSymbols.insert(tag.rawValue)
    }

    func log(_ level: LogLevel, tag: LogTag, className: String, _ message: String) {
        guard self.logAllowed(tag, className: className) else {
            return
        }
        self.activeLogger?.log(level, tag: tag, className: className, message)
    }

    fileprivate func logAllowed(_ tag: LogTag, className: String) -> Bool {
        return !self.disabledSymbols.contains(className) && !self.disabledSymbols.contains(tag.rawValue)
    }
}
