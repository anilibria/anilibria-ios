import UIKit

extension CGFloat {
    static func createFromParts(int: Int, fractional: Int) -> CGFloat {
        let first = CGFloat(int)
        let second = CGFloat(fractional)
        return first + (second == 0 ? 0 : second / pow(10, 1 + floor(log10(second))))
    }
}

func inset(_ top: CGFloat,_ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
}
