import UIKit
import FlexLayout

final class FromKeysKeysView: BaseFlexView {
    let cardHolder: UIView
    let cardView: UIView
    
    let addressView: AddressView
    let viewKeyTextField: FloatingLabelTextView
    let spendKeyTextField: FloatingLabelTextView
    
    let nextButton: UIButton
    let actionButtonsContainer: UIView
    
    required init() {
        cardHolder = UIView()
        cardView = CardView()
        
        addressView = AddressView(withQRScan: false, withAddressBook: false)
        viewKeyTextField = FloatingLabelTextView(placeholder: NSLocalizedString("view_key_(private)", comment: ""))
        spendKeyTextField = FloatingLabelTextView(placeholder: NSLocalizedString("spend_key_(private)", comment: ""))
        
        nextButton = PrimaryButton(title: "Next")
        actionButtonsContainer = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).define { flex in
            flex.addItem(addressView).height(50).marginTop(10)
            flex.addItem(viewKeyTextField).height(70).marginTop(10)
            flex.addItem(spendKeyTextField).height(70).marginTop(10)
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
