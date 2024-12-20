//
//  TeamMemberCell.swift
//  Anilibria
//
//  Created by Ivan Morozov on 23.11.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//

import UIKit

public final class TeamTagView: UIView {
    @IBOutlet var titleLabel: UILabel!

    public override func layoutSubviews() {
        super.layoutSubviews()
        smoothCorners(with: bounds.height / 2)
    }
}

public final class TeamMemberCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var internView: TeamTagView!
    @IBOutlet var vacationView: TeamTagView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        internView.titleLabel.text = L10n.Common.intern
        vacationView.titleLabel.text = L10n.Common.vacation
    }

    func configure(_ item: TeamMember) {
        self.titleLabel.text = item.name
        self.subtitleLabel.text = item.roles.lazy
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .compactMap { $0.title }
            .joined(separator: ", ")
        self.internView.isHidden = !item.isIntern
        self.vacationView.isHidden = !item.isVacation
    }
}
