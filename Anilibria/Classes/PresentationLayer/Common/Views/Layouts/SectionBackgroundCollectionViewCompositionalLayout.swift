//
//  SectionBackgroundCollectionViewCompositionalLayout.swift
//  Anilibria
//
//  Created by Ivan Morozov on 17.03.2025.
//  Copyright © 2025 Иван Морозов. All rights reserved.
//

import UIKit

open class SectionBackgroundCollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    public static let backgroundViewKind = "sectionBackground"
    public var backgroundColor: UIColor = .clear
    public var backgroundInsets: UIEdgeInsets = .zero
    public var cornerRadius: CGFloat = 0

    open override func prepare() {
        super.prepare()
        register(SectionBackgroundCollectionReusableView.self, forDecorationViewOfKind: Self.backgroundViewKind)
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var results = super.layoutAttributesForElements(in: rect)
        // Workaround to avoid displayng sectionBackground for empty section in iOS 15
        if results?.count == 1 && results?.first?.representedElementKind == Self.backgroundViewKind {
            return []
        }
        results?.enumerated().forEach { offset, attribute in
            if attribute.representedElementKind != Self.backgroundViewKind {
                return
            }
            let backgroundAttribute = SectionBackgroundViewLayoutAttributes(
                forDecorationViewOfKind: Self.backgroundViewKind,
                with: attribute.indexPath
            )

            backgroundAttribute.color = backgroundColor
            backgroundAttribute.insets = backgroundInsets
            backgroundAttribute.cornerRadius = cornerRadius
            backgroundAttribute.frame = attribute.frame
            backgroundAttribute.zIndex = attribute.zIndex
            results?[offset] = backgroundAttribute
        }
        return results
    }
}

open class SectionBackgroundViewLayoutAttributes: UICollectionViewLayoutAttributes {
    open var color: UIColor = .clear
    open var insets: UIEdgeInsets = .zero
    open var cornerRadius: CGFloat = 0

    open override func copy(with zone: NSZone? = nil) -> Any {
        guard let attributes = super.copy(with: zone) as? SectionBackgroundViewLayoutAttributes,
              let color = color.copy(with: zone) as? UIColor else {
            return super.copy(with: zone)
        }

        attributes.color = color
        return attributes
    }
}

open class SectionBackgroundCollectionReusableView: UICollectionReusableView {
    private var view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(view)

        view.constraintEdgesToSuperview(.init(
            top: .margins(),
            left: .margins(),
            bottom: .margins(),
            right: .margins()
        ))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? SectionBackgroundViewLayoutAttributes {
            view.backgroundColor = attributes.color
            layoutMargins = attributes.insets
            if attributes.cornerRadius > 0 {
                view.smoothCorners(with: attributes.cornerRadius)
            }
        }
    }
}
