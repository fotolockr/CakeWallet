import UIKit
import FlexLayout

final class ReceiveView: BaseScrollFlexView {
    let cardView: CardView
    let qrImage: UIImageView
    let addressLabel: UILabel
    let copyAddressButton: UIButton
    let switchOptionsButton: UIButton
    let optionsView: UIView
    let amountTextField: UITextField
    let paymentIdTextField: UITextField
    let integratedAddressTextField: UITextField
    let copyIntegratedButton: MiniCopyButton
    let copyPaymentIdButton: MiniCopyButton
    let resetButton: UIButton
    let paymentIdContainer: UIView
    let integratedAddressContainer: UIView
    let newPaymentId: UIButton

    required init() {
        cardView = CardView()
        qrImage = UIImageView()
        addressLabel = UILabel(fontSize: 14)
        copyAddressButton = PrimaryButton(title: NSLocalizedString("copy_address", comment: ""))
        switchOptionsButton = UIButton()
        optionsView = UIView()
        amountTextField = FloatingLabelTextField(placeholder: NSLocalizedString("amount", comment: ""), isOptional: true)
            paymentIdTextField = FloatingLabelTextField(placeholder: NSLocalizedString("Payment ID", comment: ""), isOptional: true)
        integratedAddressTextField = FloatingLabelTextField(placeholder: NSLocalizedString("Integrated address", comment: ""), isOptional: true)
        integratedAddressContainer = UIView()
        paymentIdContainer = UIView()
        resetButton = SecondaryButton(
            image: UIImage(named: "sync_icon")?
                .resized(to: CGSize(width: 16, height: 16))
                .withRenderingMode(.alwaysTemplate)
        )
        copyIntegratedButton = MiniCopyButton(textField: integratedAddressTextField)
        copyPaymentIdButton = MiniCopyButton(textField: paymentIdTextField)
        newPaymentId = SecondaryButton(
            image: UIImage(named: "settings_icon")?
                .resized(to: CGSize(width: 16, height: 16))
                .withRenderingMode(.alwaysTemplate)
        )
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        newPaymentId.titleLabel?.font = UIFont.systemFont(ofSize: 12) // fixme: hardcoded font family
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 12) // fixme: hardcoded font family
//        backgroundColor = .clear
//        rootFlexContainer.backgroundColor = .clear
//        isOpaque = true
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        amountTextField.keyboardType = .decimalPad
        switchOptionsButton.setTitle(NSLocalizedString("more_options", comment: ""), for: .normal)
        switchOptionsButton.setTitleColor(UIColor(hex: 0x00b9fc), for: .normal) // FIXME: Unnamed const
        resetButton.tintColor = .white
        newPaymentId.tintColor = .white
    }
    
    override func configureConstraints() {
        paymentIdContainer.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(paymentIdTextField).marginTop(10).height(50).grow(1).marginRight(10)
            flex.addItem(newPaymentId).height(40).width(40).marginRight(10)
            flex.addItem(copyPaymentIdButton).height(40).width(40)
        }
        
        integratedAddressContainer.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(integratedAddressTextField).marginTop(10).height(50).grow(1).marginRight(10)
            flex.addItem(copyIntegratedButton).height(40).width(40)
        }
        
        optionsView.flex.define { flex in
            flex.addItem(amountTextField).marginTop(10).height(50)
            flex.addItem(integratedAddressContainer).marginTop(10).height(50)
            flex.addItem(paymentIdContainer).marginTop(10).height(50)
        }
        
        cardView.flex.alignItems(.center).padding(20, 20, 20, 20).define { flex in
            flex.addItem(qrImage).size(CGSize(width: 160, height: 160))
            flex.addItem(addressLabel).marginTop(10)
            flex.addItem(copyAddressButton).marginTop(10).height(56).width(160)
            flex.addItem(optionsView).width(100%)
            flex.addItem(switchOptionsButton).marginTop(20)
            flex.addItem(resetButton).position(.absolute).right(20).bottom(20).height(40).width(40)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceBetween).padding(20).define { flex in
            flex.addItem(cardView).width(100%)
        }
    }
}
