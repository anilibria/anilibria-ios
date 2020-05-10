import SafariServices
import UIKit
import WebKit

// MARK: - View Controller

final class CommentsViewController: BaseViewController {
    @IBOutlet var webView: WKWebView!

    var handler: CommentsEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handler.didLoad()

        let vkButtonListlerScript = """
        var button = document.getElementById("send_post");
            button.addEventListener("click", function() {
                var messageToPost = {'ButtonId':'clickMeButton'};
                window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);
            },false);
        """

        let userScript = WKUserScript(source: vkButtonListlerScript,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: false)

        self.webView.configuration.userContentController.addUserScript(userScript)
        self.webView.configuration.userContentController.add(self, name: "buttonClicked")
    }
}

extension CommentsViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.handler.sendButtonTapped()
    }
}

extension CommentsViewController: WKNavigationDelegate {}

extension CommentsViewController: CommentsViewBehavior {
    func set(html: String, baseUrl: URL?, cookie: HTTPCookie?) {
        let loadPage: () -> Void = { [weak self] in
            self?.webView.loadHTMLString(html, baseURL: baseUrl)
        }

        let store = self.webView.configuration.websiteDataStore.httpCookieStore
        store.getAllCookies {
            if $0.contains(where: { $0.name == VKCookie.name }) == false {
                if let value = cookie {
                    store.setCookie(value, completionHandler: {
                        DispatchQueue.main.async(execute: loadPage)
                    })
                    return
                }
            }
            DispatchQueue.main.async(execute: loadPage)
        }
    }
}
