import UIKit

enum DuoDivision: Equatable {
    case book(Range<CGFloat>)
    case tabletop(Range<CGFloat>)
}

extension UIView {
    var duoDivision: DuoDivision? {
        #if HAS_UIKIT_RESERVED_REGIONS && !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, *) {
            for region in reservedRegions(kind: .division) {
                let frame = region.frame
                if frame.minY <= bounds.minY, frame.maxY >= bounds.maxY,
                   frame.minX > bounds.minX, frame.maxX < bounds.maxX {
                    return .book(frame.minX..<frame.maxX)
                }
                if frame.minX <= bounds.minX, frame.maxX >= bounds.maxX,
                   frame.minY > bounds.minY, frame.maxY < bounds.maxY {
                    return .tabletop(frame.minY..<frame.maxY)
                }
            }
        }
        #endif
        return nil
    }
}
