import UIKit

class CWTextView: UITextView {
    private let fontSize: CGFloat
    var insetX = 0 as CGFloat
    var insetY = 10 as CGFloat
    let bottomBorder: UIView
    
    required init(placeholder: String = "", fontSize: CGFloat = 18) {
        self.fontSize = fontSize
        bottomBorder = UIView()
        super.init(frame: CGRect(origin: .zero, size: .zero), textContainer: nil)
        self.placeholder = placeholder
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fontSize = 18
        bottomBorder = UIView()
        super.init(coder: aDecoder)
        addSubview(bottomBorder)
        configureView()
    }
    
    override func configureView() {
        super.configureView()
        font = UIFont(name: "Lato-Regular", size: fontSize)
        textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        addSubview(bottomBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayoutForBottomBorder()
        resizePlaceholder()
    }
    
    private func updateLayoutForBottomBorder() {
        let height = 1.5 as CGFloat
        let y = frame.size.height - height
        let width = self.frame.size.width
        bottomBorder.backgroundColor = UIColor.veryLightBlue
        bottomBorder.frame = CGRect(origin: CGPoint(x: 0, y: y), size: CGSize(width: width, height: height))
    }
}
