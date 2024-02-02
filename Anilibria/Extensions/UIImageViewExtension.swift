import Foundation
import Kingfisher
import UIKit

extension UIImageView {
    public func setImage(from url: URL?,
                         placeholder: UIImage? = nil,
                         processor: ImageProcessor? = nil,
                         completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil,
                         maxRetryCount: Int = 5) {
        guard let url = url else {
            completionHandler?(.failure(.requestError(reason: .emptyRequest)))
            return
        }
        var options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
        if let item = processor {
            options.append(.processor(item))
        }
        options.append(
            .retryStrategy(
                DelayRetryStrategy(maxRetryCount: maxRetryCount, retryInterval: .seconds(0.1))
            )
        )
        self.kf.cancelDownloadTask()
        self.kf.setImage(
            with: KF.ImageResource(downloadURL: url),
            placeholder: placeholder,
            options: options,
            completionHandler: completionHandler
        )
    }
    
    public func cancelDownloadTask() {
        self.kf.cancelDownloadTask()
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
