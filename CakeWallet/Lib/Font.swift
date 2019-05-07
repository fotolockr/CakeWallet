import UIKit

public enum FontWeight: String {
    case regular, semibold, bold
}

//public enum DeviceSqure: String {
//
//
//    case xsMax = "iPhone XS Max"
//    case x = "iPhone 7"
//}

//struct DeviceSqure {
//    let bounds = UIScreen.main.bounds
//    let width = bounds.size.width
//    let height = bounds.size.height
//    static let deviceScreenSquare = width * height
//}

public func applyFont(ofSize: CGFloat = 18, weight: FontWeight = .regular) -> UIFont {
    var selectedFont: String
    
    switch weight {
    case .regular:
        selectedFont = "Lato-Regular"
    case .semibold:
        selectedFont = "Lato-Semibold"
    case .bold:
        selectedFont = "Lato-Bold"
    }
    
    guard let customFont = UIFont(name: selectedFont, size: ofSize) else {
        fatalError("""
                Failed to load the "Lato" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
        )
    }
    
    return UIFontMetrics.default.scaledFont(for: customFont)
}
