import UIKit

public enum AppUrl {
    case phone(String)
    case web(URL?)
    case email(String)
    case appStore(String)
    case settings
    case google(String)
}

protocol AppUrlRoute {
    func open(url: AppUrl)
}

extension AppUrlRoute {
    func open(url: AppUrl) {
        var result: URL?

        switch url {
        case let .phone(value):
            if let number = value.stringByAddingPercentEncodingForURLQueryValue() {
                result = URL(string: "tel:\(number)")
            }
        case let .web(value):
            if value?.scheme?.hasPrefix("http") == true {
                result = value
            }
        case let .email(value):
            result = URL(string: "mailto:\(value)")
        case let .appStore(value):
            result = URL(string: "itms-apps://itunes.apple.com/app/\(value)")
        case .settings:
            result = URL(string: UIApplication.openSettingsURLString)
        case let .google(value):
            result = URLHelper.searchUrl(text: value)
        }

        self.open(url: result)
    }

    private func open(url: URL?) {
        guard let url = url else {
            return
        }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                self.fail(url)
            }
        }
    }

    private func fail(_ url: URL) {
        print("Can't open url: \(url)")
    }
}
