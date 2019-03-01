import UIKit
import FlexLayout

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

final class WelcomeFlowCardView: BaseFlexView {
    let card: UIView
    let imageView: UIView
    
    let textHolder: UIView
    let title: UILabel
    let descriptionText: UILabel
    
    let separatorView: UIView
    let button: UIButton
    let buttonText: UILabel
    let textColor: UIColor
    
    required init(imageView: UIView, titleText: String, descriptionText: String, textColor: UIColor) {
        card = UIView()
        self.imageView = imageView
        
        textHolder = UIView()
        title = UILabel(text: titleText)
        self.textColor = textColor
        self.descriptionText = UILabel(text: descriptionText)
        
        separatorView = UIView()
        button = UIButton()
        buttonText = UILabel(text: "Next")

        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        card.layer.cornerRadius = 12
        card.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 10, blur: 10, spread: -3)
        card.backgroundColor = Theme.current.card.background
        
        title.font = applyFont(ofSize: 20, weight: .semibold)
        title.textColor = textColor
        title.numberOfLines = 1
        
        descriptionText.font = applyFont(ofSize: 16)
        descriptionText.textColor = .greyBlue
        descriptionText.numberOfLines = 2
        descriptionText.textAlignment = .center
        
        buttonText.font = applyFont(ofSize: 18, weight: .semibold)
        buttonText.textColor = textColor
        
        imageView.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    
    func callculateCardHeight() -> CGFloat {
        switch screenType {
        case .iPhone_XSMax:
            return 350
        case .iPhones_X_XS:
            return 315
        case .iPhones_6_6s_7_8:
            return 270
        default:
            return 250
        }
    }
 
    override func configureConstraints() {
        textHolder.flex.alignItems(.center).justifyContent(.center)
            .width(100%)
            .padding(5, 20, 5, 20)
            .define{ flex in
                flex.addItem(title).marginBottom(8)
                flex.addItem(descriptionText)
        }
        
        card.flex.alignItems(.center).justifyContent(.center)
            .width(100%)
            .padding(5, 0, 60, 0)
            .marginBottom(25).define{ flex in
                flex.addItem(imageView)
                flex.addItem(textHolder)
                flex.addItem(separatorView).width(100%).height(1).backgroundColor(.veryLightBlue).marginTop(25)
                flex.addItem(button)
                    .position(.absolute)
                    .bottom(0)
                    .alignItems(.center)
                    .justifyContent(.center)
                    .width(100%)
                    .paddingTop(5)
                    .height(60).define({ wrapperFlex in wrapperFlex.addItem(buttonText) })
        }
        
        rootFlexContainer.flex.height(100%).define { flex in
            flex.addItem(card).height(callculateCardHeight())
        }
    }
}
