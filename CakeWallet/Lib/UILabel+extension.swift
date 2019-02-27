import UIKit

extension UILabel {
    convenience init(font: UIFont = UIFont.systemFont(ofSize: 16)) {
        self.init()
        self.font = font
        self.numberOfLines = 0
        self.textColor = Theme.current.text
    }
    
    convenience init(fontSize size: CGFloat = 16) {
        self.init()
        self.font = UIFont.systemFont(ofSize: size)
        self.textColor = Theme.current.text
    }
    
    convenience init(text: String = "") {
        self.init()
        self.text = text
        self.textColor = Theme.current.text
    }
    
    static func withLightText(font: UIFont = UIFont.systemFont(ofSize: 16)) -> UILabel {
        let label = UILabel(font: font)
        label.textColor = Theme.current.lightText
        label.numberOfLines = 0
        return label
    }
    
    static func withLightText(fontSize size: CGFloat = 16) -> UILabel {
        let label = UILabel(fontSize: size)
        label.textColor = Theme.current.lightText
        label.numberOfLines = 0
        return label
    }
}
