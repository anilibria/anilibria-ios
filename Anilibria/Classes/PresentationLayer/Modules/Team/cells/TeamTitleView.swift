//
//  TeamTitleView.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class TeamTitleView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!

    func configure(_ team: TeamMember.Team) {
        self.titleLabel.text = team.title
        self.infoLabel.text = team.description
    }
}
