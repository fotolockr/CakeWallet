import UIKit
import FlexLayout

final class BitrefillOrderView: BaseFlexView {
    var productName: UILabel
    var productImage: UIImageView
    let productHolder: UIView
    
    let cardView: CardView
    let phoneNumerTextField: TextField
    let amountTextField: TextField
    let limitsHolder: UIView
    let minLimitLabel: UILabel
    let maxLimitLabel: UILabel
    let emailTextField: TextField
    let paymentMethodTextField: TextField
    let payButton: PrimaryButton
    
    let amountPickerView = UIPickerView()
    let paymentMethodPickerView = UIPickerView()
    
    required init() {
        productName = UILabel(font: applyFont())
        productImage = UIImageView()
        productHolder = UIView()
        
        cardView = CardView()
        amountTextField = TextField(placeholder: "Amount", isTransparent: false)
        phoneNumerTextField = TextField(placeholder: "Phone number", isTransparent: false)
        limitsHolder = UIView()
        minLimitLabel = UILabel(text: "Min: 000")
        maxLimitLabel = UILabel(text: "Max: 000")
        emailTextField = TextField(placeholder: "Email address", isTransparent: false)
        paymentMethodTextField = TextField(placeholder: "Payment method", isTransparent: false)
        payButton = PrimaryButton(title: "Submit", font: applyFont(weight: .semibold))
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        amountPickerView.tag = 50
        paymentMethodPickerView.tag = 60
        paymentMethodTextField.textField.inputView = paymentMethodPickerView
        paymentMethodTextField.textField.text = BitrefillPaymentMethod.monero.optionFullName()
        
        amountTextField.textField.keyboardType = .decimalPad
        emailTextField.textField.keyboardType = .emailAddress
        phoneNumerTextField.textField.keyboardType = .phonePad
        
        minLimitLabel.font = applyFont(ofSize: 13)
        minLimitLabel.textColor = UIColor.wildDarkBlue
        maxLimitLabel.font = applyFont(ofSize: 13)
        maxLimitLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func configureConstraints() {
        productHolder.flex
            .direction(.row)
//            .justifyContent(.spaceBetween)
            .justifyContent(.center)
            .alignItems(.center)
            .width(100%)
            .paddingHorizontal(25)
            .define{ flex in
//                flex.addItem(productImage).width(60).height(60)
                flex.addItem(productName).width(100%)// .marginLeft(25)
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
            .padding(30, 25, 30, 25)
            .define{ flex in
                flex.addItem(productHolder).marginBottom(30)
                flex.addItem(phoneNumerTextField).marginBottom(30)
                flex.addItem(amountTextField).width(100%).marginBottom(5)
                flex.addItem(limitsHolder).width(50%).marginBottom(30)
                flex.addItem(emailTextField).width(100%).marginBottom(30)
                flex.addItem(paymentMethodTextField).width(100%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(25, 0, 45, 0)
            .define{ flex in
                flex.addItem(cardView)
                flex.addItem(payButton).width(90%).height(56)
        }
    }
}
