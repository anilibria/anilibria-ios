import Foundation
import Kingfisher

extension UIImageView {
    public func setImage(from url: URL?,
                         placeholder: UIImage? = nil,
                         processor: ImageProcessor? = nil,
                         completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        var options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
        if let item = processor {
            options.append(.processor(item))
        }
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: options,
                         completionHandler: completionHandler)
    }
}

extension UIImageView {
    @IBInspectable
    var templateImage: UIImage? {
        get {
            return self.image
        }
        set {
            self.image = newValue?.withRenderingMode(.alwaysTemplate)
        }
    }
}
