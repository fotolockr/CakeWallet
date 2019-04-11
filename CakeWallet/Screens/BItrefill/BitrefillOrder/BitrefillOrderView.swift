import UIKit
import FlexLayout

final class BitrefillOrderView: BaseFlexView {
    var productName: UILabel
    var productImage: UIImageView
    let productHolder: UIView
    
    let cardView: CardView
    let amountTextField: TextField
    let limitsHolder: UIView
    let minLimitLabel: UILabel
    let maxLimitLabel: UILabel
    let emailTextField: TextField
    let paymentMethodTextField: TextField
    let payButton: PrimaryButton
    
//    let amountPickerView = UIPickerView()
    let paymentMethodPickerView = UIPickerView()
    
    required init() {
        productName = UILabel(font: applyFont())
        productImage = UIImageView()
        productHolder = UIView()
        
        cardView = CardView()
        amountTextField = TextField(placeholder: "Amount", isTransparent: false)
        limitsHolder = UIView()
        minLimitLabel = UILabel(text: "Min: 000")
        maxLimitLabel = UILabel(text: "Max: 000")
        emailTextField = TextField(placeholder: "Email address", isTransparent: false)
        paymentMethodTextField = TextField(placeholder: "Payment method", isTransparent: false)
        payButton = PrimaryButton(title: "Pay", font: applyFont(weight: .semibold))
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
//        amountPickerView.tag = 50
        paymentMethodPickerView.tag = 60
        paymentMethodTextField.textField.inputView = paymentMethodPickerView
        paymentMethodTextField.textField.text = BitrefillPaymentMethod.monero.optionFullName()
        
        amountTextField.textField.keyboardType = .decimalPad
        emailTextField.textField.keyboardType = .emailAddress
        
        minLimitLabel.font = applyFont(ofSize: 13)
        minLimitLabel.textColor = UIColor.wildDarkBlue
        maxLimitLabel.font = applyFont(ofSize: 13)
        maxLimitLabel.textColor = UIColor.wildDarkBlue
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
        
        limitsHolder.flex
            .direction(.row)
            .alignItems(.center)
            .justifyContent(.spaceBetween)
            .define { flex in
                flex.addItem(minLimitLabel).width(100)
                flex.addItem(maxLimitLabel).width(100)
        }
        
        cardView.flex
            .width(90%)
            .padding(35, 25, 35, 25)
            .define{ flex in
                flex.addItem(productHolder).marginBottom(35)
                flex.addItem(amountTextField).width(100%).marginBottom(5)
                flex.addItem(limitsHolder).width(50%).marginBottom(35)
                flex.addItem(emailTextField).width(100%).marginBottom(35)
                flex.addItem(paymentMethodTextField).width(100%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(20, 0, 30, 0)
            .define{ flex in
                flex.addItem(cardView)
                flex.addItem(payButton).width(90%).height(56)
        }
    }
}
