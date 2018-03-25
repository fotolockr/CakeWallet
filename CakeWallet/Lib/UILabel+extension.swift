//
//  UILabel+extension.swift
//  Wallet
//
//  Created by Cake Technologies 17.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

//final class AdaptiveFont: UIFont {
//    convenience init(name: String, size: CGFloat) {
//
//        self.init()
//    }
//}

extension UIFont {
    enum CustomFont {
        case avenirNextRegular
        case avenirNextMedium
        case avenirNextHeavy
        case avenirNextBold
        case avenirNextDeniBold
        
        var fontFamily: String {
            let value: String
            
            switch self {
            case .avenirNextRegular:
                value = "AvenirNext-Regular"
            case .avenirNextMedium:
                value = "Avenir-Medium"
            case .avenirNextBold:
                value = "AvenirNext-Bold"
            case .avenirNextHeavy:
                value = "Avenir-Heavy"
            case .avenirNextDeniBold:
                value = "AvenirNext-DemiBold"
            }
            
            return value
        }
    }
    
    convenience init?(_ customFont: CustomFont, size: CGFloat) {
        let height = UIScreen.main.bounds.height
        let calculatedSize: CGFloat
        
        // FIX-ME: HARDCODE
        
        switch height {
        case 480.0:
            calculatedSize = size * 0.7
        case 568.0:
            calculatedSize = size * 0.8
        case 667.0:
            calculatedSize = size * 0.9
        case 736.0:
            calculatedSize = size
        default:
            calculatedSize = size
        }
        
        self.init(name: customFont.fontFamily, size: calculatedSize)
    }
    
    static func avenirNext(size: CGFloat) -> UIFont {
        return UIFont(.avenirNextRegular, size: size)!
    }
    
    static func avenirNextMedium(size: CGFloat) -> UIFont {
        return UIFont(.avenirNextMedium, size: size)!
    }
    
    static func avenirNextHeavy(size: CGFloat) -> UIFont {
        return UIFont(.avenirNextHeavy, size: size)!
    }
    
    static func avenirNextBold(size: CGFloat) -> UIFont {
        return UIFont(.avenirNextBold, size: size)!
    }
    
    static func avenirNextDemiBold(size: CGFloat) -> UIFont {
        return UIFont(.avenirNextDeniBold, size: size)!
    }
}

extension UILabel {
    @objc
    public var substituteFontName : String {
        get {
            return self.font.fontName;
        }
        set {
            let fontNameToTest = self.font.fontName.lowercased();
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
    
    convenience init(font: UIFont = UIFont.avenirNext(size: 15)) {
        self.init()
        self.font = font
    }
}
