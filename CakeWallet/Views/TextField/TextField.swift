import UIKit
import FlexLayout

class TextField: BaseFlexView {
    var placeholder: String {
        get { return textField.placeholder ?? "" }
        set { setPlaceholder(newValue) }
    }
    var fontSize: Int
    var isTransparent: Bool
    var textField: UITextField
    let borderView: UIView
    
    required init(placeholder: String = "", fontSize: Int = 18, isTransparent: Bool = true) {
        self.fontSize = fontSize
        self.isTransparent = isTransparent
        textField = UITextField()
        borderView = UIView()
        
        super.init()
        setPlaceholder(placeholder)
    }
    
    required init() {
        self.fontSize = 18
        self.isTransparent = true
        textField = UITextField()
        borderView = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        textField.font = applyFont(ofSize: fontSize, weight: .regular)
        backgroundColor = .clear
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .width(100%)
            .backgroundColor(isTransparent ? Theme.current.container.background : .clear)
            .define{ flex in
                flex.addItem(textField).width(100%).marginBottom(11)
                flex.addItem(borderView).width(100%).height(1.5).backgroundColor(UIColor.veryLightBlue)
        }
    }
    
    private func setPlaceholder(_ placeholder: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.wildDarkBlue,
                NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: CGFloat(fontSize))!
            ]
        )
    }
}
