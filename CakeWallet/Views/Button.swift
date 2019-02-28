import UIKit

class Button: UIButton {
    private static let leftOffset = 15 as CGFloat
    private static let rightOffset = 15 as CGFloat
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    convenience init(title: String, fontSize: CGFloat) {
        self.init(title: title, font: UIFont.systemFont(ofSize: fontSize))
    }
    
    convenience init(title: String, font: UIFont) {
        self.init(title: title)
        // self.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        titleLabel?.font = font
    }
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        
        // ?
        setImage(image, for: .normal)
        
        configureView()
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        // ?
        setTitle(title, for: .normal)
        
        configureView()
        contentEdgeInsets = UIEdgeInsets(top: 0, left: Button.leftOffset, bottom: 0, right: Button.rightOffset)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height * 0.25
    }
    
    override func configureView() {
        backgroundColor = Theme.current.primaryButton.background
        setTitleColor(Theme.current.primaryButton.text, for: .normal)
        layer.masksToBounds = false
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 2, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        contentHorizontalAlignment = .center
        titleLabel?.font = applyFont(weight: .semibold)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
}
