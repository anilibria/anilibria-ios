import UIKit

extension UIColor {
    convenience init?(hexString: String) {
        if let rgbValue = UInt(hexString, radix: 16) {
            let red = CGFloat((rgbValue >> 16) & 0xFF) / 255
            let green = CGFloat((rgbValue >> 8) & 0xFF) / 255
            let blue = CGFloat(rgbValue & 0xFF) / 255
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else {
            return nil
        }
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = Int(r*255)<<16 | Int(g*255)<<8 | Int(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
