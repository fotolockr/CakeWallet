import UIKit
import FlexLayout

final class ReceiveView: BaseScrollFlexView {
    let cardView: UIView
    let qrImage: UIImageView
    let addressLabel: UILabel
    let copyAddressButton: UIButton
    let switchOptionsButton: UIButton
    let optionsView: UIView
    let amountTextField: UITextField
    let paymentIdTextField: TextField
    let integratedAddressTextField: UITextField
    let resetButton: UIButton
    let paymentIdContainer: UIView
    let integratedAddressContainer: UIView
    let newPaymentId: UIButton
    let buttonsContainer: UIView
    let copyButton: UIButton
    let topSectionWrapper: UIView
    let qrCodeWrapper: UIView

    required init() {
        cardView = UIView()
        qrImage = UIImageView()
        addressLabel = UILabel(fontSize: 14)
        copyAddressButton = PrimaryButton(title: NSLocalizedString("copy_address", comment: ""))
        switchOptionsButton = UIButton()
        optionsView = UIView()
        amountTextField = FloatingLabelTextField(placeholder: NSLocalizedString("amount", comment: ""), isOptional: true)
        paymentIdTextField = TextField(placeholder: "Payment ID (optional)", fontSize: 15)
        integratedAddressTextField = FloatingLabelTextField(placeholder: NSLocalizedString("Integrated address", comment: ""), isOptional: true)
        integratedAddressContainer = UIView()
        paymentIdContainer = UIView()
        resetButton = SecondaryButton(title: "Reset")
        newPaymentId = SecondaryButton(title: "New Payment ID")
        copyButton = UIButton()
        topSectionWrapper = UIView()
        qrCodeWrapper = UIView()
        buttonsContainer = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        copyAddressButton.backgroundColor = UIColor.turquoiseBlue
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        addressLabel.font = applyFont(ofSize: 14)
        amountTextField.keyboardType = .decimalPad
        switchOptionsButton.setTitle(NSLocalizedString("more_options", comment: ""), for: .normal)
        switchOptionsButton.setTitleColor(UIColor.turquoiseBlue, for: .normal)
        resetButton.tintColor = .white
        newPaymentId.tintColor = .white
        
        copyButton.setImage(UIImage(named: "qr_code_icon"), for: .normal)
        copyButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        copyButton.layer.cornerRadius = 5
        copyButton.backgroundColor = UIColor.whiteSmoke
    }
    
    override func configureConstraints() {
        topSectionWrapper.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.start).width(100%).define {flex in
            flex.addItem(qrCodeWrapper).alignItems(.center).width(100%).addItem(qrImage).size(CGSize(width: 150, height: 150))
        }
        
        paymentIdContainer.flex
            .define { flex in
                flex.addItem(paymentIdTextField).width(100%)
                flex.addItem(copyButton).width(35).height(35).position(.absolute).right(0).top(-10)
        }
        
//        paymentIdContainer.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
//            flex.addItem(paymentIdTextField).marginTop(10).height(60).grow(1).marginRight(10)
//            flex.addItem(copyPaymentIdButton).height(40).width(40)
//        }
        
//        integratedAddressContainer.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
//            flex.addItem(integratedAddressTextField).marginTop(10).height(50).grow(1).marginRight(10)
//            flex.addItem(copyIntegratedButton).height(40).width(40)
//        }
        
        optionsView.flex.define { flex in
            flex.addItem(amountTextField).marginTop(10).height(50)
//            flex.addItem(integratedAddressContainer).marginTop(10).height(50)
            flex.addItem(paymentIdContainer).marginTop(25)
        }
        
        cardView.flex.alignItems(.center).padding(5, 10, 20, 10).define { flex in
            copyAddressButton.layer.borderWidth = 0.75
            copyAddressButton.layer.borderColor = UIColor(red: 152, green: 228, blue: 227).cgColor
            
            flex.addItem(topSectionWrapper)
            flex.addItem(addressLabel).marginTop(10)
            flex.addItem(copyAddressButton).marginTop(15).height(56).width(100%).backgroundColor(UIColor(red: 235, green: 248, blue: 250))
            flex.addItem(optionsView).width(100%)
            flex.addItem(switchOptionsButton).marginTop(20)
        }
        
        buttonsContainer.flex.justifyContent(.spaceBetween).direction(.row).define { flex in
            flex.addItem(resetButton).height(56).width(45%)
            flex.addItem(newPaymentId).height(56).width(45%)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceBetween).padding(10).backgroundColor(.clear).define { flex in
            flex.addItem(cardView).width(100%)
//            flex.addItem(buttonsContainer).marginTop(15).width(100%).height(56)
        }
    }
}
