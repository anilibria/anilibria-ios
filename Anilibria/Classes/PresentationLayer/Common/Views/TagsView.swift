//
//  TagsView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 06.06.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

public final class TagsView: UIView {
    private var arrangedSubviews: [TagView] = []
    private let space: CGFloat = 8

    private var contentSize: CGSize = .zero {
        didSet {
            if contentSize != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        contentSize
    }

    func set(tags: [Tag]) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        arrangedSubviews.removeAll()

        for tag in tags {
            let tagView = TagView(tag: tag)
            addSubview(tagView)
            tagView.layoutIfNeeded()
            arrangedSubviews.append(tagView)
        }
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        var currentPoint: CGPoint = .zero
        for tag in arrangedSubviews {
            let tagWidth = tag.bounds.width
            if currentPoint.x + tagWidth > width {
                currentPoint.x = 0
                currentPoint.y += tag.bounds.height + space
            }
            tag.frame.origin = currentPoint
            currentPoint.x += space + tagWidth
        }
        if let last = arrangedSubviews.last {
            contentSize = CGSize(width: width, height: last.frame.maxY)
        }
    }
}

extension TagsView {

    struct Tag {
        let icon: UIImage
        let title: String
    }

    private final class TagView: UIView {
        private let iconView = UIImageView()
        private let titleLabel = UILabel()

        init(tag: Tag) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false

            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 4
            stackView.alignment = .center
            self.addSubview(stackView)
            stackView.constraintEdgesToSuperview(.init(top: 4, left: 6, bottom: 4, right: 6))

            iconView.image = tag.icon
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = .Text.main
            stackView.addArrangedSubview(iconView)

            titleLabel.text = tag.title
            titleLabel.font = UIFont.font(ofSize: 12, weight: .regular)
            titleLabel.textColor = .Text.secondary
            stackView.addArrangedSubview(titleLabel)

            self.layer.borderWidth = 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            self.layer.cornerRadius = bounds.height / 2
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            self.layer.borderColor = UIColor.Tint.separator.cgColor
        }
    }
}
