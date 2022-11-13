//
//  TorrentFileCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit

public final class TorrentFileCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    private let formatter = ByteCountFormatter()

    public override func awakeFromNib() {
        super.awakeFromNib()
        if let window = UIApplication.getWindow() {
            self.rippleContainerView.widthAnchor.constraint(equalToConstant: window.frame.width - 32).isActive = true
        }
    }

    func configure(_ item: TorrentFile) {
        self.titleLabel.text = item.name
        self.descLabel.text = formatter.string(for: item.length)
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
