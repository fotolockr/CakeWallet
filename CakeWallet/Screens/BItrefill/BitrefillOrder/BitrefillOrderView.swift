import UIKit
import FlexLayout

final class BitrefillOrderView: BaseFlexView {
    var productName: UILabel
    var productImage: UIImageView
    let productHolder: UIView
    
    let cardView: CardView
    let amountTextField: TextField
    let emailTextField: TextField
    let payButton: PrimaryButton
    
    required init() {
        productName = UILabel(font: applyFont())
        productImage = UIImageView()
        productHolder = UIView()
        
        cardView = CardView()
        amountTextField = TextField(placeholder: "Amount", isTransparent: false)
        emailTextField = TextField(placeholder: "Email address", isTransparent: false)
        payButton = PrimaryButton(title: "Pay", font: applyFont(weight: .semibold))
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        productHolder.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .width(100%)
            .define{ flex in
                flex.addItem(productImage).width(75).height(75)
                flex.addItem(productName).width(100%).marginLeft(25)
        }
        
        cardView.flex
            .width(90%)
            .padding(45, 25, 45, 25)
            .define{ flex in
                flex.addItem(productHolder).marginBottom(45)
                flex.addItem(amountTextField).width(100%).marginBottom(45)
                flex.addItem(emailTextField).width(100%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(30, 0, 30, 0)
            .define{ flex in
                flex.addItem(cardView)
                flex.addItem(payButton).width(90%).height(56)
        }
    }
}
