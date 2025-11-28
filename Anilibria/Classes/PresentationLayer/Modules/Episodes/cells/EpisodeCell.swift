//
//  EpisodeCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 27.11.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

final class EpisodeCell: RippleViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    func configure(_ item: PlaylistItem) {
        self.titleLabel.text = item.fullName

        self.imageView.setImage(from: item.preview,
                                placeholder: DefaultPlaceholder())
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
