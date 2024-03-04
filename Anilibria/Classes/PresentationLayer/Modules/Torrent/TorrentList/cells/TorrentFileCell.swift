//
//  TorrentFileCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 13.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import UIKit
import Combine

public final class TorrentFileCell: RippleViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var dowloadSpeedLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!

    private var bag = Set<AnyCancellable>()

    public override func awakeFromNib() {
        super.awakeFromNib()
        if let window = UIApplication.getWindow() {
            self.rippleContainerView.widthAnchor.constraint(equalToConstant: window.frame.width - 32).isActive = true
        }
    }

    func configure(_ model: TorrentListItemViewModel) {
        self.titleLabel.text = model.item.torrentFile.name
        self.apply(model: model)
        model.operationUpdated = { [weak self, weak model] in
            if let model { self?.apply(model: model) }
        }
    }

    private func apply(model: TorrentListItemViewModel) {
        bag.removeAll()
        let current = model.item.fileSize.binaryCountFormatted
        let expected = model.item.torrentFile.length.binaryCountFormatted
        self.descLabel.text = "\(current)/\(expected)"
        self.progressView.progress = 0

        if let operation = model.operation {
            operation.progress.map { Float($0/100) }.sink { [weak progressView] value in
                progressView?.progress = value
            }.store(in: &bag)

            operation.speed.sink { [weak dowloadSpeedLabel] value in
                dowloadSpeedLabel?.text = value
            }.store(in: &bag)

            operation.isCompleted.filter { $0 }.sink { [weak dowloadSpeedLabel] _ in
                dowloadSpeedLabel?.text = ""
            }.store(in: &bag)

            operation.downloadedSize.map { $0.binaryCountFormatted }.sink { [weak descLabel] value in
                descLabel?.text = "\(value)/\(expected)"
            }.store(in: &bag)

        } else if model.item.status == .ready {
            progressView.progress = 1
            dowloadSpeedLabel.text = ""
        } else {
            dowloadSpeedLabel.text = ""
        }
    }

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.layer.zPosition = CGFloat.createFromParts(int: layoutAttributes.indexPath.section,
                                                       fractional: layoutAttributes.indexPath.row)
    }
}
