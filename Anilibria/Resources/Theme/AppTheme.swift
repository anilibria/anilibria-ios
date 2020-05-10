import UIKit

public protocol AppTheme {
    func apply()

    // MARK: - Colors

    var white: UIColor { get }
    var black: UIColor { get }
    var red: UIColor { get }
    var darkRed: UIColor { get }

    var defaultFont: AppFont? { get }
}

public struct MainTheme: AppTheme {
    public static var shared: AppTheme = MainTheme()

    public func apply() {
        self.configureNavBar()
        self.configureTextView()
        self.configureCollectionView()
    }

    func configureNavBar() {
        let navbar = UINavigationBar.appearance()
        navbar.isTranslucent = true
        navbar.isOpaque = false
        navbar.titleTextAttributes = [
            .foregroundColor: black,
            .font: UIFont.font(ofSize: 17, weight: .medium)
        ]
        navbar.barTintColor = self.white
        navbar.tintColor = black
        navbar.shadowImage = UIImage()
    }

    func configureTextView() {
        UITextView.appearance().tintColor = self.black
        UITextField.appearance().tintColor = self.black
    }

    func configureCollectionView() {
        UICollectionView.appearance().isPrefetchingEnabled = false
    }

    // MARK: - Colors

    public var white: UIColor = .white
    public var black: UIColor = .black
    public var red: UIColor = .red
    public var darkRed: UIColor = #colorLiteral(red: 0.707420184, green: 0, blue: 0, alpha: 1)

    // MARK: - Font

    public var defaultFont: AppFont?
}
