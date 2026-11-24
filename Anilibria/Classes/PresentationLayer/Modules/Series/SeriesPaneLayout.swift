import UIKit

final class SeriesPaneLayout: UIStackView {
    var onEpisodePaneChanged: ((Bool) -> Void)?

    private enum Mode: Equatable {
        case compact
        case wide
        case folded(DuoDivision)
    }

    private var mode: Mode?
    private var overviewSize: NSLayoutConstraint?

    override func layoutSubviews() {
        let target = layoutMode
        if target != mode {
            update(to: target)
        }
        super.layoutSubviews()
    }

    private var layoutMode: Mode {
        if let division = duoDivision {
            switch division {
            case let .book(gap) where gap.lowerBound - bounds.minX >= 260 && bounds.maxX - gap.upperBound >= 260:
                return .folded(division)
            case let .tabletop(gap) where gap.lowerBound - bounds.minY >= 180 && bounds.maxY - gap.upperBound >= 180:
                return .folded(division)
            default:
                break
            }
        }
        return bounds.width >= 640 ? .wide : .compact
    }

    private func update(to target: Mode) {
        guard let overview = arrangedSubviews.first else { return }
        let wasExpanded = mode != nil && mode != .compact
        mode = target
        overviewSize?.isActive = false
        overviewSize = nil
        switch target {
        case .compact, .wide:
            axis = .horizontal
            distribution = .fillEqually
            spacing = 0
        case let .folded(.book(gap)):
            axis = .horizontal
            distribution = .fill
            spacing = gap.upperBound - gap.lowerBound
            overviewSize = overview.widthAnchor.constraint(equalToConstant: gap.lowerBound - bounds.minX)
        case let .folded(.tabletop(gap)):
            axis = .vertical
            distribution = .fill
            spacing = gap.upperBound - gap.lowerBound
            overviewSize = overview.heightAnchor.constraint(equalToConstant: gap.lowerBound - bounds.minY)
        }
        let expanded = target != .compact
        if expanded != wasExpanded { onEpisodePaneChanged?(expanded) }
        overviewSize?.isActive = true
    }
}
