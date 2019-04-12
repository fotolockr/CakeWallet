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
    let payButton: PrimaryLoadingButton
    
    let amountPickerView = UIPickerView()
    let paymentMethodPickerView = UIPickerView()
    
    required init() {
        productName = UILabel(font: applyFont(ofSize: 21, weight: .bold))
        productImage = UIImageView()
        productHolder = UIView()
        
        cardView = CardView()
        amountTextField = TextField(placeholder: "Amount", fontSize: 17, isTransparent: false)
        phoneNumerTextField = TextField(placeholder: "Phone number", fontSize: 17, isTransparent: false)
        limitsHolder = UIView()
        minLimitLabel = UILabel(text: "Min: 000")
        maxLimitLabel = UILabel(text: "Max: 000")
        emailTextField = TextField(placeholder: "Email address", fontSize: 17, isTransparent: false)
        paymentMethodTextField = TextField(placeholder: "Payment method", fontSize: 17, isTransparent: false)
        payButton = PrimaryLoadingButton()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        payButton.setTitle("Submit", for: .normal)
        
        amountPickerView.tag = 50
        paymentMethodPickerView.tag = 60
        paymentMethodTextField.textField.inputView = paymentMethodPickerView
        paymentMethodTextField.textField.text = BitrefillPaymentMethod.monero.optionFullName()
        
        amountTextField.textField.keyboardType = .decimalPad
        emailTextField.textField.keyboardType = .emailAddress
        phoneNumerTextField.textField.keyboardType = .phonePad
        
        minLimitLabel.font = applyFont(ofSize: 11)
        minLimitLabel.textColor = UIColor.wildDarkBlue
        maxLimitLabel.font = applyFont(ofSize: 11)
        maxLimitLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func configureConstraints() {
        productHolder.flex
            .direction(.row)
//            .justifyContent(.spaceBetween)
            .justifyContent(.center)
            .alignItems(.center)
            .width(100%)
//            .paddingHorizontal(25)
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
            .padding(30, 25, 35, 25)
            .define{ flex in
                flex.addItem(productHolder).marginBottom(50)
                flex.addItem(phoneNumerTextField).marginBottom(25)
                flex.addItem(amountTextField).width(100%).marginBottom(5)
                flex.addItem(limitsHolder).width(50%).marginBottom(25)
                flex.addItem(emailTextField).width(100%).marginBottom(25)
                flex.addItem(paymentMethodTextField).width(100%)
        }
        
        rootFlexContainer.flex
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .padding(25, 0, 25, 0)
            .define{ flex in
                flex.addItem(cardView)
                flex.addItem(payButton).width(90%).height(56)
        }
    }
}
