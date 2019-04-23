import UIKit
import FlexLayout

extension UITextView {
    public var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX + 10, y: labelY + 2, width: labelWidth, height: labelHeight)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = applyFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.wildDarkBlue
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = self.text.count > 0

        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
}

class TextView: BaseFlexView {
    var placeholder: String
    var fontSize: Int
    var isTransparent: Bool
    var textField: UITextView
    let borderView: UIView
    
    required init(placeholder: String = "", fontSize: Int = 18, isTransparent: Bool = true) {
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.isTransparent = isTransparent
        textField = UITextView()
        borderView = UIView()
        
        super.init()
    }
    
    required init() {
        self.placeholder = ""
        self.fontSize = 18
        self.isTransparent = true
        textField = UITextView()
        borderView = UIView()
        
        super.init()
    }
    
    override func didChangeValue(forKey key: String) {
        print("HEY")
    }
    
    override func configureView() {
        super.configureView()
        
        print("CONFIGURE VIEW")
 
        
        textField.placeholder = placeholder
        textField.font = applyFont(ofSize: fontSize, weight: .regular)
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .width(100%)
            .grow(1)
            .backgroundColor(isTransparent ? Theme.current.card.background : .white)
            .define{ flex in
                flex.addItem(textField).width(100%).marginBottom(4)
                flex.addItem(borderView).width(100%).height(1.5).backgroundColor(UIColor.veryLightBlue)
        }
    }
}
