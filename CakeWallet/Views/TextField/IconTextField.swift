import UIKit
import FlexLayout

class IconTextField: BaseFlexView {
    let placeholder: String
    let fontSize: Int
    let withTextAlignmentReverse: Bool
    let textField: UITextField
    let borderView: UIView
    let buttonsView: UIView
    
    let qrCodeButton: UIButton
    let addressBookButton: UIButton
    
    required init(placeholder: String, fontSize: Int = 18, withTextAlignmentReverse: Bool = false) {
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.withTextAlignmentReverse = withTextAlignmentReverse
        textField = UITextField()
        borderView = UIView()
        buttonsView = UIView()
        
        
        // TODO: buttons have to be separated
        qrCodeButton = UIButton()
        addressBookButton = UIButton()
        
        qrCodeButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        qrCodeButton.backgroundColor = .clear
        qrCodeButton.layer.cornerRadius = 5
        qrCodeButton.backgroundColor = UIColor.whiteSmoke
        
        addressBookButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        addressBookButton.backgroundColor = .clear
        addressBookButton.layer.cornerRadius = 5
        addressBookButton.backgroundColor = UIColor.whiteSmoke
        
        if let qrCodeImage = UIImage(named: "qr_code_icon") {
            qrCodeButton.setImage(qrCodeImage, for: .normal)
        }
        
        if let addressBookImage = UIImage(named: "address_book") {
            addressBookButton.setImage(addressBookImage, for: .normal)
        }
        // TODO: buttons have to be separated
        
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        textField.font = applyFont(ofSize: fontSize, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 191, green: 201, blue: 215)]
        )
        
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 0))
        textField.rightViewMode = .always
    }
    
    override func configureConstraints() {
        let border = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1.5))
        
        buttonsView.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .width(80)
            .define{ flex in
                flex.addItem(qrCodeButton).width(35).height(35)
                flex.addItem(addressBookButton).width(35).height(35).marginLeft(5)
        }
    
        rootFlexContainer.flex
            .width(100%)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(textField).width(100%).marginBottom(11)
                flex.addItem(border).width(100%).backgroundColor(UIColor.veryLightBlue)
                
                flex.addItem(buttonsView).position(.absolute).top(-10).right(0)
        }
    }
}
