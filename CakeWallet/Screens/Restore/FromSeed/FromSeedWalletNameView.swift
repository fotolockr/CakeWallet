import UIKit
import FlexLayout

final class FromSeedWalletNameView: BaseFlexView {
    let cardHolder: UIView
    let cardView: UIView
    let walletNameTextField: UITextField
    let nextButton: UIButton
    let actionButtonsContainer: UIView
    
    required init() {
        cardHolder = UIView()
        cardView = CardView()
        
        walletNameTextField = FloatingLabelTextField(placeholder: "Wallet name")
        nextButton = PrimaryButton(title: "Next")
        actionButtonsContainer = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        cardView.flex.padding(UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)).define { flex in
            flex.addItem(walletNameTextField).height(50)
        }
        
        actionButtonsContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(nextButton).height(56).width(45%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)).define { flex in
                flex.addItem(cardHolder).justifyContent(.center).width(100%).height(90%)
                    .addItem(cardView).justifyContent(.center).width(100%)
                flex.addItem(actionButtonsContainer).width(100%)
        }
    }
}
