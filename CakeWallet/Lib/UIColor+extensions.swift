import UIKit

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        let _red = CGFloat(red / 255)
        let _green = CGFloat(green / 255)
        let _blue = CGFloat(blue / 255)
        self.init(red: _red, green: _green, blue: _blue, alpha: 1)
    }
}
