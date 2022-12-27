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

    func configure(_ item: SeriesFile) {
        self.titleLabel.text = item.torrentFile.name
        let current = formatter.string(for: item.fileSize) ?? ""
        let expected = formatter.string(for: item.torrentFile.length) ?? ""
        self.descLabel.text = "\(current)/\(expected)"
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
