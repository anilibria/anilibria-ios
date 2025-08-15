import Foundation
import Kingfisher
import UIKit

extension UIImageView {
    public func setImage(from url: URL?,
                         placeholder: ImagePlaceholder? = nil,
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
            placeholder: PlaceholderAdapter(placeholder),
            options: options,
            completionHandler: completionHandler
        )
    }
    
    public func cancelDownloadTask() {
        self.kf.cancelDownloadTask()
    }
}

public protocol ImagePlaceholder {
    func addTo(view: UIView)
    func removeFrom(view: UIView)
}

struct PlaceholderAdapter: Placeholder {
    private let placeholder: ImagePlaceholder

    init?(_ placeholder: ImagePlaceholder?) {
        guard let placeholder else { return nil }
        self.placeholder = placeholder
    }

    func add(to imageView: KFCrossPlatformImageView) {
        placeholder.addTo(view: imageView)
    }

    func remove(from imageView: KFCrossPlatformImageView) {
        placeholder.removeFrom(view: imageView)
    }
}

final class DefaultPlaceholder: UIView, ImagePlaceholder {
    private let imageView = UIImageView()

    init(offset: CGPoint = .zero) {
        super.init(frame: .zero)
        setup(offset)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(.zero)
    }

    private func setup(_ offset: CGPoint) {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
            imageView.widthAnchor.constraint(equalToConstant: 44),
            imageView.heightAnchor.constraint(equalToConstant: 44),
        ])

        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .Text.secondary
        backgroundColor = .Tint.shimmer
    }

    func addTo(view: UIView) {
        self.removeFromSuperview()
        view.addSubview(self)
        self.constraintEdgesToSuperview()
    }

    func removeFrom(view: UIView) {
        self.removeFromSuperview()
    }
}
