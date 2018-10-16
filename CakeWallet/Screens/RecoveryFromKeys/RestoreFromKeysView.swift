import UIKit
import FlexLayout
import JVFloatLabeledTextField

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        if let existedLayer = layer.sublayers?.filter({ $0.name == "bottom_border" }).first {
            existedLayer.removeFromSuperlayer()
        }
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        border.name = "bottom_border"
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

final class FloatingLabelTextView: JVFloatLabeledTextView {
    convenience init(placeholder: String = "") {
        self.init()
        self.placeholder = placeholder
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addBottomBorderWithColor(color: UIColor(hex: 0xe0e9f6), width: 2)
    }
    
    override func configureView() {
        super.configureView()
        font = UIFont.systemFont(ofSize: 14)
        placeholderTextColor = UIColor(hex: 0x9bacc5) // FIXME: Unnamed cons
    }
}


final class RestoreFromKeysView: BaseScrollFlexViewWithBottomSection {
    let cardView: CardView
    let walletNameTextField: FloatingLabelTextView
    let addressView: AddressView
    let viewKeyTextField: FloatingLabelTextView
    let spendKeyTextField: FloatingLabelTextView
    let restoreFromHeightView: RestoreFromHeightView
    let recoverButton: UIButton
    let viewKeyTextFieldWrapperView: UIView
    let spendKeyTextFieldWrapperView: UIView
    
    required init() {
        cardView = CardView()
        walletNameTextField = FloatingLabelTextView(placeholder: NSLocalizedString("wallet_name", comment: ""))
        addressView = AddressView(withQRScan: false)
        viewKeyTextField = FloatingLabelTextView(placeholder: NSLocalizedString("view_key_(private)", comment: ""))
        spendKeyTextField = FloatingLabelTextView(placeholder: NSLocalizedString("spend_key_(private)", comment: ""))
        restoreFromHeightView = RestoreFromHeightView()
        recoverButton = PrimaryButton(title: NSLocalizedString("restore_wallet", comment: ""))
        viewKeyTextFieldWrapperView = UIView()
        spendKeyTextFieldWrapperView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressView.textView.delegate = self
        viewKeyTextField.isScrollEnabled = false
        viewKeyTextField.delegate = self
        spendKeyTextField.isScrollEnabled = false
        spendKeyTextField.delegate = self
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).define { flex in
            flex.addItem(walletNameTextField).height(50)
            flex.addItem(addressView).width(100%).marginTop(10)
            flex.addItem(viewKeyTextFieldWrapperView).direction(.row) //.height(60).width(100%).marginTop(10)
                .addItem(viewKeyTextField).marginTop(10).width(100%).height(56).grow(1)
            flex.addItem(spendKeyTextFieldWrapperView).direction(.row)
                .addItem(spendKeyTextField).marginTop(10).width(100%).height(56).grow(1) //.height(60).width(100%).marginTop(10)
            flex.addItem(restoreFromHeightView).width(100%).marginTop(10)
        }
        
        rootFlexContainer.flex.alignItems(.center).justifyContent(.spaceAround).padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).define { flex in
            flex.addItem(cardView).marginTop(20).width(100%)
        }
        
        bottomSectionView.flex.padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)).addItem(recoverButton).width(100%).height(56)//.margin(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
    }
}
