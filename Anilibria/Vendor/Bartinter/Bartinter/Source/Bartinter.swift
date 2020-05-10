//
//  Bartinter.swift
//
//  Created by Maxim Kotliar on 6/15/18.
//

import UIKit
import CoreImage

public extension Bartinter {

    struct Configuration {
        public static var defaultAnimationDuration: TimeInterval = 0.2
        public static var defaultThrottleDelay: TimeInterval = 0.2
        public static var defaultAnimationType: UIStatusBarAnimation = .fade
        public static var defaultMidPoint: CGFloat = 0.6
        public static var defaultAntiFlickRange: CGFloat = 0.08

        var animationDuration = defaultAnimationDuration
        var animationType = defaultAnimationType
        var midPoint = defaultMidPoint
        var antiFlickRange = defaultAntiFlickRange
        var throttleDelay = defaultThrottleDelay

        public init(animationDuration: TimeInterval = defaultAnimationDuration,
                    animationType: UIStatusBarAnimation = defaultAnimationType,
                    midPoint: CGFloat  = defaultMidPoint,
                    antiFlickRange: CGFloat = defaultAntiFlickRange,
                    throttleDelay: TimeInterval = defaultThrottleDelay) {
            self.animationDuration = animationDuration
            self.animationType = animationType
            self.midPoint = midPoint
            self.antiFlickRange = antiFlickRange
            self.throttleDelay = throttleDelay
        }
    }
}

public final class Bartinter: UIViewController {
    public var configuration: Configuration {
        didSet {
            throttler.maxInterval = configuration.throttleDelay
        }
    }

    private lazy var throttler = {
        return Throttler(interval: self.configuration.throttleDelay)
    }()

    public init(_ configuration: Configuration = Configuration()) {
        self.configuration = configuration
        Bartinter.swizzleIfNeeded()
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getLayer(completion: @escaping (CALayer) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let layer = self?.parent?.view.layer else { return }
            completion(layer)
        }
    }

    private func calculateStatusBarAreaAvgLuminance(_ completion: @escaping (CGFloat) -> Void) {
        let scale: CGFloat = 0.5
        let size = UIApplication.shared.statusBarFrame.size
        getLayer { [weak self] layer in
            self?.throttler.throttle {
                UIGraphicsBeginImageContextWithOptions(size, false, scale)
                guard let context = UIGraphicsGetCurrentContext() else { return }
                layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                guard let averageLuminance = image?.averageLuminance else { return }
                UIGraphicsEndImageContext()
                DispatchQueue.main.async {
                    completion(averageLuminance)
                }
            }
        }
    }

    private var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            guard oldValue != statusBarStyle else { return }
            UIView.animate(withDuration: configuration.animationDuration) {
                self.parent?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return configuration.animationType
    }

    @objc public func refreshStatusBarStyle() {
        calculateStatusBarAreaAvgLuminance { [weak self] avgLuminance in
            guard let strongSelf = self else { return }
            let antiFlick = strongSelf.configuration.antiFlickRange / 2
            if avgLuminance <= strongSelf.configuration.midPoint - antiFlick {
                strongSelf.statusBarStyle = .lightContent
            } else if avgLuminance >= strongSelf.configuration.midPoint + antiFlick {
                strongSelf.statusBarStyle = .default
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        view.frame = .zero
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.view.layoutIfNeeded()
        parent?.view.redrawDelegate = self
        refreshStatusBarStyle()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.subviews.forEach { $0.removeFromSuperview() }
        parent?.view.redrawDelegate = nil
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshStatusBarStyle()
    }

    public func attach(to viewController: UIViewController) {
        viewController.addChild(self)
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
    }

    public func detach() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension Bartinter: UIViewRedrawDelegate {
    public func didLayoutSubviews() {
        refreshStatusBarStyle()
    }
}

private extension UIImage {
    var averageLuminance: CGFloat? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage,
                                                 kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0,
                                      width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        let r = CGFloat(bitmap[0]) / 255
        let g = CGFloat(bitmap[1]) / 255
        let b = CGFloat(bitmap[2]) / 255
        // Luminance coeficents taken from https://en.wikipedia.org/wiki/Relative_luminance
        let luminance = 0.212 * r + 0.715 * g + 0.073 * b
        return luminance
    }
}

extension UIViewController {
    
    @objc var swizzledChildViewControllerForStatusBarStyle: UIViewController? {
        return statusBarUpdater ?? self.swizzledChildViewControllerForStatusBarStyle
    }
    
    fileprivate static func setupChildViewControllerForStatusBarStyleSwizzling() {
        let original = #selector(getter: UIViewController.childForStatusBarStyle)
        let swizzled = #selector(getter: UIViewController.swizzledChildViewControllerForStatusBarStyle)
        
        let originalMethod = class_getInstanceMethod(UIViewController.self,
                                                     original)
        let swizzledMethod = class_getInstanceMethod(UIViewController.self,
                                                     swizzled)
        
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

fileprivate protocol UIViewRedrawDelegate: class {
    func didLayoutSubviews()
}

private extension UIView {
    
    @objc func swizzledLayoutSubviews() {
        self.swizzledLayoutSubviews()
        redrawDelegate?.didLayoutSubviews()
    }
    
    static func setupSetNeedsLayoutSwizzling() {
        let original = #selector(UIView.layoutSubviews)
        let swizzled = #selector(UIView.swizzledLayoutSubviews)
        
        let originalMethod = class_getInstanceMethod(UIView.self,
                                                     original)
        let swizzledMethod = class_getInstanceMethod(UIView.self,
                                                     swizzled)
        
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

public extension Bartinter {
    static var isSwizzlingEnabled: Bool = true
    
    static var isSwizzlingPerformed: Bool = false
    static func swizzleIfNeeded() {
        guard isSwizzlingEnabled && !isSwizzlingPerformed else { return }
        UIViewController.setupChildViewControllerForStatusBarStyleSwizzling()
        UIView.setupSetNeedsLayoutSwizzling()
        isSwizzlingPerformed = true
    }
}

private var statusBarUpdaterHandle = "statusBarUpdaterHandle"
public extension UIViewController {
    
    private(set) var statusBarUpdater: Bartinter? {
        get {
            return objc_getAssociatedObject(self,
                                            &statusBarUpdaterHandle) as? Bartinter
        }
        
        set {
            // Dispatching to next runloop iteration
            DispatchQueue.main.async {
                self.statusBarUpdater?.detach()
                newValue?.attach(to: self)
            }
            objc_setAssociatedObject(self, &statusBarUpdaterHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Updates StatusBar Appearance Automatically
    @IBInspectable var updatesStatusBarAppearanceAutomatically: Bool {
        get {
            return statusBarUpdater != nil
        }
        set {
            switch newValue {
            case true:
                statusBarUpdater = Bartinter()
            case false:
                statusBarUpdater = nil
            }
        }
    }
}

private var redrawDelegateHandle = "redrawDelegateHandle"
private extension UIView {
    weak var redrawDelegate: UIViewRedrawDelegate? {
        get {
            return objc_getAssociatedObject(self, &redrawDelegateHandle) as? UIViewRedrawDelegate
        }
        
        set {
            objc_setAssociatedObject(self, &redrawDelegateHandle, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
