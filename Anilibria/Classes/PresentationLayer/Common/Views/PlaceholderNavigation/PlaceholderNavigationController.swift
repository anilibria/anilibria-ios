//
//  PlaceholderNavigationController.swift
//  AniLiberty
//
//  Created by Ivan Morozov on 17.04.2026.
//  Copyright © 2026 Иван Морозов. All rights reserved.
//

import UIKit


final class PlaceholderNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: .iconAnilibria.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .Tint.shimmer
        imageView.alpha = 0.55
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.widthAnchor.constraint(equalToConstant: 250)
        ])
        imageView.layer.zPosition = -1
    }
}
