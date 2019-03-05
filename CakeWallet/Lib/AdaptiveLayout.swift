import UIKit
import FlexLayout

class AdaptiveLayout {
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
    
    // TODO: smart adjusments for other devices (increasing sizes from milestones)
    func getSize(forLarge large: Int, forBig big: Int, defaultSize: Int) -> CGFloat {
        switch screenType {
        case .iPhone_XSMax:
            return CGFloat(large)
        case .iPhones_X_XS, .iPhones_6Plus_6sPlus_7Plus_8Plus, .iPhone_XR:
            return CGFloat(big)
        default:
            return CGFloat(defaultSize)
        }
    }
}

let adaptiveLayout = AdaptiveLayout()
