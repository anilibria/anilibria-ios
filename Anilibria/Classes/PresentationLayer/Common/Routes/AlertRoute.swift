protocol AlertRoute: AnyObject {
    func openAlert(title: String, message: String, buttons: [AlertButton], tapBlock: Action<Int>?, userData: Any?)
    func openAlert(title: String, message: String, buttons: [String], tapBlock: Action<Int>?)
    func openAlert(title: String, message: String)
    func openAlert(message: String)
}

extension AlertRoute {
    func openAlert(title: String, message: String, buttons: [AlertButton], tapBlock: Action<Int>?, userData: Any?) {
        MRAppAlertController.alert(title,
                                   message: message,
                                   buttons: buttons,
                                   userData: userData,
                                   tapBlock: tapBlock)
    }

    func openAlert(title: String, message: String) {
        MRAppAlertController.alert(title, message: message)
    }

    func openAlert(message: String) {
        MRAppAlertController.alert(message)
    }

    func openAlert(title: String, message: String, buttons: [String], tapBlock: Action<Int>?) {
        MRAppAlertController.alert(title, message: message, buttons: buttons, tapBlock: tapBlock)
    }

    func openAlert(title: String, message: String, buttons: [AlertButton], tapBlock: Action<Int>?) {
        MRAppAlertController.alert(title, message: message, buttons: buttons, tapBlock: tapBlock)
    }
}
