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
    let buttonsContainer: UIView
    
    let topSectionWrapper: UIView
    let qrCodeWrapper: UIView

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
        resetButton = SecondaryButton(title: "Reset")
        copyIntegratedButton = MiniCopyButton(textField: integratedAddressTextField)
        copyPaymentIdButton = MiniCopyButton(textField: paymentIdTextField)
        newPaymentId = SecondaryButton(title: "New Payment ID")
        
        topSectionWrapper = UIView()
        qrCodeWrapper = UIView()
        buttonsContainer = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        copyAddressButton.backgroundColor = .vividBlue
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        amountTextField.keyboardType = .decimalPad
        switchOptionsButton.setTitle(NSLocalizedString("more_options", comment: ""), for: .normal)
        switchOptionsButton.setTitleColor(UIColor(hex: 0x00b9fc), for: .normal) // FIXME: Unnamed const
        resetButton.tintColor = .white
        newPaymentId.tintColor = .white
    }
    
    override func configureConstraints() {
        topSectionWrapper.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.start).width(100%).define {flex in
            flex.addItem(qrCodeWrapper).alignItems(.center).width(100%).addItem(qrImage).size(CGSize(width: 150, height: 160)).marginTop(20)
        }
        
        paymentIdContainer.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(paymentIdTextField).marginTop(10).height(60).grow(1).marginRight(10)
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
        
        cardView.flex.alignItems(.center).padding(5, 20, 20, 20).define { flex in
            flex.addItem(topSectionWrapper)
            flex.addItem(addressLabel).marginTop(10)
            flex.addItem(copyAddressButton).marginTop(10).height(56).width(160)
            flex.addItem(optionsView).width(100%)
            flex.addItem(switchOptionsButton).marginTop(20)
        }
        
        buttonsContainer.flex.justifyContent(.spaceBetween).direction(.row).define { flex in
            flex.addItem(resetButton).height(56).width(45%)
            flex.addItem(newPaymentId).height(56).width(45%)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceBetween).padding(20).backgroundColor(.clear).define { flex in
            flex.addItem(cardView).width(100%)
            flex.addItem(buttonsContainer).marginTop(15).width(100%).height(56)
        }        
    }
}
