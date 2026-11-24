//
//  EpisodeCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

final class EpisodeCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var watchedButton: UIButton!

    private let timeFormatter = FormatterFactory.time.create()
    private var cancellabe: AnyCancellable?

    override func awakeFromNib() {
        super.awakeFromNib()
        timeLabel.superview?.smoothCorners(with: 6)
        progressView.transform = .init(scaleX: 1, y: 2)
    }

    func configure(_ episode: EpisodeViewModel) {
        self.titleLabel.text = episode.item.episode
        self.subtitleLabel.text = episode.item.title
        self.timeLabel.text = timeFormatter.string(from: episode.item.duration)

        cancellabe = watchedButton.publisher(for: .touchUpInside).sink {
            episode.didTapOnWatched(episode)
        }

        if episode.timecode.isWatched {
            progressView.progress = 1
            effectView.isHidden = true
            watchedButton.setImage(.System.checkmarkAppFill, for: .normal)
        } else {
            progressView.progress = Float(episode.timecode.time) / Float(episode.item.duration)
            effectView.isHidden = false
            watchedButton.setImage(.System.app, for: .normal)
        }

        progressView.isHidden = progressView.progress == 0

        self.imageView.setImage(
            from: episode.item.preview,
            placeholder: DefaultPlaceholder()
        )

        if episode.item.preview == nil {
            effectView.isHidden = true
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(
            int: layoutAttributes.indexPath.section,
            fractional: layoutAttributes.indexPath.row
        )
    }
}
