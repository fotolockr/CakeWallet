import UIKit
import FlexLayout
import PinLayout

enum ExchangeCardType: String {
    case deposit, receive, unknown
}

final class ExchangePickerItemView: BaseView {
    static let rowHeight: CGFloat = 56
    static let rowWidth: CGFloat = 56
    let label: UILabel
    let rotationAngle: CGFloat
    
    required init() {
        label = UILabel(fontSize: 15)
        rotationAngle = 90 * (.pi/180)
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: ExchangePickerItemView.rowWidth, height: ExchangePickerItemView.rowHeight)))
    }
    
    override func configureView() {
        super.configureView()
        label.textAlignment = .center
        label.backgroundColor = .clear
        transform = CGAffineTransform(rotationAngle: rotationAngle)
        unselect()
        backgroundColor = .clear
        addSubview(label)
    }
    
    override func configureConstraints() {
        label.frame = CGRect(origin: .zero, size: CGSize(width: ExchangePickerItemView.rowWidth, height: ExchangePickerItemView.rowHeight))
    }
    
    func select() {
        label.textColor = .white
    }

    func unselect() {
        label.textColor = .spaceViolet
    }
}

protocol ExchangableCardView {
    var exchangePickerView: ExchangePickerView { get }
    var addressContainer: AddressView { get }
    var walletNameLabel: UILabel { get }
}

extension ExchangableCardView {
        func hideAddressViewField() {
            addressContainer.isHidden = true
            addressContainer.flex.height(0)
//            setNeedsLayout()
        }
    
        func showAddressViewField() {
            addressContainer.isHidden = false
            addressContainer.flex.height(nil)
//            setNeedsLayout()
        }
    
        func hideWalletName() {
            walletNameLabel.isHidden = true
            walletNameLabel.flex.height(0)
//            setNeedsLayout()
        }
    
        func showWalletName() {
            walletNameLabel.isHidden = false
            walletNameLabel.flex.height(nil)
//            setNeedsLayout()
        }
    
        func setupWallet(name: String) {
//            walletNameLabel.text = name
        }
}

final class ExchangePickerView: BaseFlexView {
    let pickerView: UIPickerView
    let selectedItemView: UIView
    
    required init() {
        pickerView = UIPickerView()
        selectedItemView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 56, height: 56)))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        let rotationAngle: CGFloat = -90 * (.pi/180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        pickerView.tag = 202
        selectedItemView.layer.masksToBounds = false
        selectedItemView.layer.cornerRadius = 15
        selectedItemView.backgroundColor = .vividBlue
        selectedItemView.layer.applySketchShadow(color: .vividBlue, alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
        backgroundColor = .clear
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.backgroundColor(.clear).define { flex in
            flex.addItem(selectedItemView).position(.absolute).alignSelf(.center).height(56).width(56)
            flex.addItem(pickerView).width(100%).height(56)
        }
    }
}

final class DepositExchangeCardView: BaseFlexView, ExchangableCardView {
    var walletNameLabel: UILabel
    let exchangePickerView: ExchangePickerView
    let titleLabel: UILabel
    let addressContainer: AddressView
    let amountTextField: UITextField
    let amountTitleLabel: UILabel
    let amountLabel: UILabel
    let minLabel: UILabel
    let maxLabel: UILabel
    let limitsRow: UIView
    
    required init() {
        titleLabel = UILabel(fontSize: 16)
        exchangePickerView = ExchangePickerView()
        amountTextField = FloatingLabelTextField(placeholder: NSLocalizedString("amount", comment: ""))
        addressContainer = AddressView()
        amountTitleLabel = UILabel(fontSize: 14)
        amountLabel = UILabel(fontSize: 24)
        walletNameLabel = UILabel(fontSize: 15)
        minLabel = UILabel(fontSize: 12)
        maxLabel = UILabel(fontSize: 12)
        limitsRow = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.text = NSLocalizedString("deposit", comment: "")
        titleLabel.textAlignment = .center
        amountTextField.keyboardType = .decimalPad
//        addressContainer.textView.placeholder = NSLocalizedString("refund_address", comment: "")
        layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.16, x: 0, y: 16, blur: 46, spread: -5)
        backgroundColor = .white
        walletNameLabel.textAlignment = .center
        minLabel.textColor = .wildDarkBlue
        maxLabel.textColor = .wildDarkBlue
        walletNameLabel.textColor = .wildDarkBlue
        amountLabel.textColor = .spaceViolet
        amountTitleLabel.text = NSLocalizedString("you_will_send", comment: "")
        amountLabel.text = "0"
        amountTitleLabel.textAlignment = .center
        amountLabel.textAlignment = .center
        amountTitleLabel.textColor = . wildDarkBlue
        amountLabel.textColor = .spaceViolet
        amountTitleLabel.isHidden = true
        amountLabel.isHidden = true
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.cornerRadius = frame.size.width * 0.07
    }
    
    override func configureConstraints() {
        limitsRow.flex.direction(.row).define { flex in
            flex.addItem(minLabel).height(100%)
            flex.addItem(maxLabel).height(100%)
        }
        
        rootFlexContainer.flex.padding(20, 20, 30, 20).backgroundColor(.clear).define { flex in
            flex.addItem(titleLabel).width(100%)
            flex.addItem(exchangePickerView).height(56).margin(UIEdgeInsets(top: 15, left: -20, bottom: 0, right: -20))
            flex.addItem(walletNameLabel).width(100%).height(20).marginTop(5).marginBottom(5)
            flex.addItem(amountTitleLabel).width(100%).marginTop(10)
            flex.addItem(amountLabel).width(100%).marginTop(5).marginBottom(15)
            flex.addItem(amountTextField).width(100%).height(50)
            flex.addItem(limitsRow).width(100%).marginTop(5).height(20)
            flex.addItem(addressContainer).marginTop(10)
        }
    }
}

final class ReceiveExchangeCardView: BaseFlexView, ExchangableCardView {
    var walletNameLabel: UILabel
    let addressContainer: AddressView
    let exchangePickerView: ExchangePickerView
    let titleLabel: UILabel
    let amountTitleLabel: UILabel
    let amountLabel: UILabel
    let minLabel: UILabel
    let maxLabel: UILabel
    let limitsRow: UIView
    let amountTextField: UITextField
    
    required init() {
        titleLabel = UILabel(fontSize: 16)
        amountTitleLabel = UILabel(fontSize: 14)
        amountLabel = UILabel(fontSize: 24)
        addressContainer = AddressView()
        exchangePickerView = ExchangePickerView()
        walletNameLabel = UILabel(fontSize: 15)
        minLabel = UILabel(fontSize: 12)
        maxLabel = UILabel(fontSize: 12)
        limitsRow = UIView()
        amountTextField = FloatingLabelTextField(placeholder: NSLocalizedString("amount", comment: ""))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.text = NSLocalizedString("Receive", comment: "")
        titleLabel.textAlignment = .center
        amountTitleLabel.textColor = . wildDarkBlue
        amountLabel.textColor = .spaceViolet
        layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.16, x: 0, y: 16, blur: 46, spread: -5)
        amountTitleLabel.text = NSLocalizedString("you_will_receive", comment: "")
        amountLabel.text = "0"
        amountTitleLabel.textAlignment = .center
        amountLabel.textAlignment = .center
        backgroundColor = .white
        walletNameLabel.textAlignment = .center
        walletNameLabel.textColor = .wildDarkBlue
        minLabel.textColor = .wildDarkBlue
        maxLabel.textColor = .wildDarkBlue
        amountTextField.keyboardType = .decimalPad
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.cornerRadius = frame.size.width * 0.07
    }
    
    override func configureConstraints() {
        limitsRow.flex.direction(.row).define { flex in
            flex.addItem(minLabel).height(100%)
            flex.addItem(maxLabel).height(100%)
        }
        
        rootFlexContainer.flex.padding(20, 20, 20, 20).backgroundColor(.clear).define { flex in
            flex.addItem(titleLabel).width(100%)
            flex.addItem(exchangePickerView).height(56).margin(UIEdgeInsets(top: 15, left: -20, bottom: 0, right: -20))
            flex.addItem(walletNameLabel).width(100%).height(20).marginTop(5).marginBottom(5)
            flex.addItem(amountTitleLabel).width(100%).marginTop(10)
            flex.addItem(amountLabel).width(100%).marginTop(5).marginBottom(15)
            flex.addItem(amountTextField).width(100%).height(50).marginBottom(15)
            flex.addItem(addressContainer)
            flex.addItem(limitsRow).width(100%).marginTop(5).height(20)
        }
    }
}

final class ExchangeView: BaseScrollFlexView {
    let depositCardView: ExchangeCardView
    let receiveCardView: ExchangeCardView
    
    let arrowDownImageView: UIImageView
    let clearButton: UIButton
    let exchangeButton: UIButton
    let buttonsRow: UIView
    let descriptionView: UIView
    let dispclaimerLabel: UILabel
    let exchangeLogoImage: UIImageView
    let exchangeDescriptionLabel: UILabel
    
    required init() {
        depositCardView = ExchangeCardView(cardType: ExchangeCardType.deposit, cardTitle: "Deposit")
        receiveCardView = ExchangeCardView(cardType: ExchangeCardType.deposit, cardTitle: "Receive")
        arrowDownImageView = UIImageView(image: UIImage(named: "arrow_down_dotted"))
        clearButton = SecondaryButton(title: NSLocalizedString("clear", comment: ""))
        exchangeButton = PrimaryButton(title: NSLocalizedString("exchange", comment: ""))
        buttonsRow = UIView()
        exchangeDescriptionLabel = UILabel(fontSize: 14)
        descriptionView = UIView()
        exchangeLogoImage = UIImageView(image: UIImage(named: "morphtoken_logo"))
        dispclaimerLabel = UILabel(fontSize: 12)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        exchangeDescriptionLabel.textColor = .wildDarkBlue
        dispclaimerLabel.textColor = .lightGray
        dispclaimerLabel.textAlignment = .center
    }
    
    override func configureConstraints() {
        buttonsRow.flex.direction(.row).justifyContent(.spaceBetween).define { rowFlex in
            rowFlex.addItem(exchangeButton).height(56).width(100%)
        }
        
        descriptionView.flex.direction(.row).justifyContent(.center).define { flex in
            flex.addItem(exchangeLogoImage).width(32).height(32)
            flex.addItem(exchangeDescriptionLabel).marginLeft(10).height(20)
        }
        
        rootFlexContainer.flex.padding(20, 15, 20, 20).define { flex in
            flex.addItem(depositCardView).marginBottom(25)
            flex.addItem(receiveCardView).marginBottom(10)
            flex.addItem(dispclaimerLabel).width(100%).height(20).marginBottom(25)
            flex.addItem(buttonsRow)
            flex.addItem(descriptionView).width(100%).marginTop(15).alignItems(.center)
        }
    }
}

// MARK: UITextViewDelegate

extension BaseView: UITextViewDelegate {
    @objc
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.count > 0
        }
        
        let fixedWidth = textView.frame.size.width
        let newHeight = textView.sizeThatFits(
            CGSize(
                width: fixedWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
        ).height
        
        let newSize = CGSize(width: fixedWidth, height: newHeight)
        textView.flex.size(newSize).markDirty()
        setNeedsLayout()
    }
}


extension UIPickerView {
    func hideSelectionIndicator() {
        guard self.subviews.count >= 2 else { return }
        
        self.subviews[1].isHidden = true
        self.subviews[2].isHidden = true
    }
}
