import UIKit
import FlexLayout


//class CustomTextField: UITextField {
//    init() {
//        super.init(frame: .zero)
//        configureView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func configureView() {
//        super.configureView()
//
//        backgroundColor = UIColor.black
////
////        placeholder = "asdad"
////
//        print(frame)
//        print("-----------")
////
////        let bottomLine = CALayer()
////        bottomLine.frame = CGRect(x: 0, y: 10, width: 30, height: 2)
////        bottomLine.backgroundColor = UIColor.black.cgColor
////        borderStyle = UITextBorderStyle.none
////        layer.addSublayer(bottomLine)
////
//////        layer.backgroundColor = UIColor.black.cgColor
//    }
//}
//
//extension CustomTextField {
//    func setActionButtons(_ image: UIImage) {
//        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
//        iconView.image = image
//
//        let iconContainerView: UIView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
//        iconContainerView.addSubview(iconView)
//
//        leftView = iconContainerView
//        leftViewMode = .always
//    }
//}










class MyTextField: BaseFlexView {
//    let width: Int?
    let placeholder: String
    let fontSize: Int
    let withActionButtons: Bool
    var actionButtons: Array<UIView>
    let withTextAlignmentReverse: Bool
    let textField: UITextField
    let borderView: UIView
    let actionButtonsView: UIView
    
    required init(
//        width: Int?,
        placeholder: String,
        fontSize: Int = 18,
        withActionButtons: Bool = false,
        actionButtons: Array<UIView> = [UIView](),
        withTextAlignmentReverse: Bool = false
    ) {
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.withActionButtons = withActionButtons
        self.actionButtons = actionButtons
        self.withTextAlignmentReverse = withTextAlignmentReverse
        textField = UITextField()
        borderView = UIView()
        actionButtonsView = UIView()
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func appendActionButtons(buttonsToAppend buttons: Array<UIView>) {
        for buttonView in buttons {
            self.actionButtons.append(buttonView)
        }
    }
    
    override func configureView() {
        super.configureView()
        
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.font = applyFont(ofSize: fontSize, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightBlueGrey]
        )
        
        if withTextAlignmentReverse {
            let placeholderStringLength = placeholder.count
            
            print(placeholderStringLength)
            print("--------------")
//            var width: CGFloat = textField.text.size(withFont: textField.font).width
            
            print("==============")
            print(self.frame.width)
            print(self.bounds)
            print("==============")
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
            view.backgroundColor = UIColor.red
            textField.leftView = view
//            textField.leftView.backgroundColor = UIColor.red
            textField.leftViewMode = .always
            
            // TODO: append action buttons to rightView
//            textField.rightView =
        }
    }
    
    override func configureConstraints() {
        let withActionButtons = actionButtons.count > 0
        
        if withActionButtons {
            
        }
        
        rootFlexContainer.flex
            .width(200)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(textField).marginBottom(10)
                flex.addItem(borderView).width(100%).height(2).backgroundColor(UIColor.lightBlueGrey)
                
//                if withActionButtons {
//                    flex.addItem(actionButtonsView).width(20).height(20).backgroundColor(.red).position(.absolute).right(0).top(0)
//                }
        }
    }
}

final class ExchangeCardView: BaseFlexView {
    let cardTitle: UILabel
    let pickerRow: UIView
    let pickerButton: UIView
    let textField: MyTextField
    let actionTextField: MyTextField
    
    required init(cardTitle: String) {
        self.cardTitle = UILabel(text: cardTitle)
        pickerRow = UIView()
        pickerButton = UIView()
        textField = MyTextField(placeholder: "0.000", fontSize: 21, withTextAlignmentReverse: true)
        actionTextField = MyTextField(placeholder: "Refund address", fontSize: 16,  withActionButtons: true)
        
        super.init()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        rootFlexContainer.layer.cornerRadius = 12
        rootFlexContainer.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 0, blur: 20, spread: -10)
        rootFlexContainer.backgroundColor = Theme.current.card.background
        
        rootFlexContainer.flex
            .justifyContent(.start)
            .alignItems(.center)
            .padding(20, 15, 20, 15)
            .marginBottom(25)
            .define{ flex in
                flex.addItem(cardTitle).marginBottom(15)
                flex.addItem(textField).marginBottom(20)
//                flex.addItem(actionTextField).position(<#T##value: Flex.Position##Flex.Position#>)
        }
    }
}
