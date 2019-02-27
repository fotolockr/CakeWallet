import UIKit
import FlexLayout

final class WelcomeFlowCardView: BaseFlexView {
    let card: UIView
    let image: UIImageView
    let title: UILabel
    let descriptionText: UILabel
    let separatorView: UIView
    let button: UIButton
    let buttonText: UILabel
    let cardColor: UIColor
    
    required init(withImage imageName: String, withTitle titleText: String, withDescription descrText: String, withColor color: UIColor) {
        card = UIView()
        image = UIImageView(image: UIImage(named: imageName))
        title = UILabel(text: titleText)
        descriptionText = UILabel(text: descrText)
        separatorView = UIView()
        button = UIButton()
        buttonText = UILabel(text: "Next")
        cardColor = color
        
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
        title.textColor = cardColor
        title.numberOfLines = 1
        
        descriptionText.font = applyFont(ofSize: 16)
        descriptionText.textColor = .greyBlue
        descriptionText.numberOfLines = 2
        descriptionText.textAlignment = .center
        
        buttonText.font = applyFont(ofSize: 18, weight: .semibold)
        buttonText.textColor = cardColor
    }
 
    override func configureConstraints() {
        card.flex.alignItems(.center)
            .width(100%)
            .padding(0, 0, 50, 0)
            .marginBottom(25).define{ flex in
                flex.addItem(image)
                flex.addItem(title).marginBottom(8)
                flex.addItem(descriptionText).padding(0, 15, 0, 15)
                flex.addItem(separatorView).width(100%).height(1).backgroundColor(.veryLightBlue).marginTop(25)
                flex.addItem(button)
                    .position(.absolute)
                    .bottom(0)
                    .alignItems(.center)
                    .justifyContent(.center)
                    .width(100%)
                    .height(50).define({ wrapperFlex in wrapperFlex.addItem(buttonText) })
        }
        
        rootFlexContainer.flex.alignItems(.center).padding(0, 15, 0, 15).define { flex in
            flex.addItem(card)
        }
    }
}
