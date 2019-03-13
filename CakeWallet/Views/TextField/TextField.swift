import UIKit
import FlexLayout

class TextField: BaseFlexView {
    let placeholder: String
    let fontSize: Int
    let withTextAlignmentReverse: Bool
    let textField: UITextField
    let borderView: UIView
    
    required init(placeholder: String, fontSize: Int = 18, withTextAlignmentReverse: Bool = false) {
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.withTextAlignmentReverse = withTextAlignmentReverse
        textField = UITextField()
        borderView = UIView()
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.font = applyFont(ofSize: fontSize, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 191, green: 201, blue: 215)]
        )
        
        // TODO
        if withTextAlignmentReverse {
            let placeholderStringLength = placeholder.count
            //            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: textField.frame.height))
            
            //            textField.leftView = view
            //            textField.leftViewMode = .always
        }
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .width(100%)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(textField).width(100%).marginBottom(11)
                flex.addItem(borderView).width(100%).height(1.5).backgroundColor(UIColor.veryLightBlue)
        }
    }
}
