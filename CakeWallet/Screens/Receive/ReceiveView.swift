import UIKit
import FlexLayout


final class ReceiveView: BaseScrollFlexView {
    let cardView: UIView
    let qrCodeWrapper: UIView
    let qrImage: UIImageView
    let addressLabel: UILabel
    let copyAddressButton: UIButton
    let switchOptionsButton: UIButton
    let optionsView: UIView
    let amountTextField: TextField
    
    let paymentIdContainer: UIView
    let paymentIdTextField: TextField
    let paymentIdCopyButton: IconedCopyButton
    
    let integratedAddressContainer: UIView
    let integratedAddressTextField: TextField
    let integratedAddressCopyButton: IconedCopyButton
    
    let resetButton: UIButton
    let newPaymentId: UIButton
    let buttonsContainer: UIView
    let copyButton: UIButton
    let topSectionWrapper: UIView
    
    required init() {
        cardView = UIView()
        qrImage = UIImageView()
        addressLabel = UILabel(fontSize: 14)
        copyAddressButton = PrimaryButton(title: NSLocalizedString("copy_address", comment: ""))
        switchOptionsButton = UIButton()
        optionsView = UIView()
        amountTextField = TextField(placeholder: NSLocalizedString("amount", comment: ""), fontSize: 15)
        paymentIdTextField = TextField(placeholder: "Payment ID (optional)", fontSize: 15)
        integratedAddressTextField = TextField(placeholder: NSLocalizedString("Integrated address (optional)", comment: ""), fontSize: 15)
        integratedAddressContainer = UIView()
        paymentIdContainer = UIView()
        resetButton = SecondaryButton(title: "Reset", fontSize: 14)
        newPaymentId = SecondaryButton(title: "New payment ID", fontSize: 14)
        copyButton = UIButton()
        topSectionWrapper = UIView()
        qrCodeWrapper = UIView()
        buttonsContainer = UIView()
        paymentIdCopyButton = IconedCopyButton()
        integratedAddressCopyButton = IconedCopyButton()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        copyAddressButton.backgroundColor = UIColor.turquoiseBlue
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        addressLabel.font = applyFont(ofSize: 14)
        amountTextField.textField.keyboardType = .decimalPad
        switchOptionsButton.setTitle(NSLocalizedString("more_options", comment: ""), for: .normal)
        switchOptionsButton.setTitleColor(UIColor.turquoiseBlue, for: .normal)
    }
    
    override func configureConstraints() {
        topSectionWrapper.flex
            .alignItems(.center)
            .width(100%)
            .paddingHorizontal(adaptiveLayout.getSize(forLarge: 50, forBig: 35, defaultSize: 30))
            .define {flex in
                flex.addItem(qrCodeWrapper).alignItems(.center).width(100%).addItem(qrImage).size(CGSize(width: 150, height: 150))
                flex.addItem(addressLabel).marginTop(15)
        }
        
        paymentIdContainer.flex
            .define { flex in
                flex.addItem(paymentIdTextField).width(100%)
                flex.addItem(paymentIdCopyButton).width(35).height(35).position(.absolute).right(0).top(-10)
        }
        
        integratedAddressContainer.flex
            .define { flex in
                flex.addItem(integratedAddressTextField).width(100%)
                flex.addItem(integratedAddressCopyButton).width(35).height(35).position(.absolute).right(0).top(-10)
        }
        
        buttonsContainer.flex.justifyContent(.center).direction(.row).define { flex in
            flex.addItem(resetButton).height(38).width(150).marginRight(7)
            flex.addItem(newPaymentId).height(38).width(150).marginLeft(7)
        }
        
        optionsView.flex
            .paddingHorizontal(9)
            .define { flex in
                flex.addItem(amountTextField).marginTop(25)
                flex.addItem(paymentIdContainer).marginTop(30)
                flex.addItem(integratedAddressContainer).marginTop(30)
                flex.addItem(buttonsContainer).marginTop(30).width(100%)
        }
        
        cardView.flex.alignItems(.center).padding(5, 10, 20, 10).define { flex in
            copyAddressButton.layer.borderWidth = 0.75
            copyAddressButton.layer.borderColor = UIColor(red: 152, green: 228, blue: 227).cgColor
            
            flex.addItem(topSectionWrapper)
            
            flex.addItem(copyAddressButton).marginTop(20).height(56).width(100%).backgroundColor(UIColor(red: 235, green: 248, blue: 250))
            flex.addItem(optionsView).width(100%).marginTop(adaptiveLayout.getSize(forLarge: 15, forBig: 10, defaultSize: 0))
            flex.addItem(switchOptionsButton).marginTop(20)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceBetween).padding(10).backgroundColor(.clear).define { flex in
            flex.addItem(cardView).width(100%).marginTop(10)
        }
    }
}
