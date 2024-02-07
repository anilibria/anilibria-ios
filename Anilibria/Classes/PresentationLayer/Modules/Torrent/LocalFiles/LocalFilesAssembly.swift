//
//  LocalFilesRouter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 07.02.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

// MARK: - Route

protocol LocalFilesRoute {
    func showLocalFiles()
}

extension LocalFilesRoute where Self: RouterProtocol {
    func showLocalFiles() {
        let document = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["org.matroska.mkv"])
        document.allowsDocumentCreation = false
        let closeButton = UIBarButtonItem(
            image: .iconClose,
            style: .plain,
            target: document,
            action: #selector(document.dismiss(animated:completion:))
        )
        document.additionalTrailingNavigationBarButtonItems = [closeButton]
        document.modalPresentationStyle = .fullScreen
        self.controller.present(document, animated: true)
    }
}
