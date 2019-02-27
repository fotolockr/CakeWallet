import UIKit

class CheckBox: UIButton {
//    var cvstPosition: Double
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "close_symbol")! as UIImage
    
    var handler: ((Bool) -> Void)?
    
    var isChecked: Bool = true {
        didSet{
            if isChecked == false {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
        
//    override func configureView() {
//        super.configureView()
//        backgroundColor = Theme.current.secondaryButton.background
//        layer.applySketchShadow(color: UIColor(hex: 0x9bacc5), alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
//    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    @objc
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if let handler = handler {
                handler(!isChecked)
            }
            isChecked = !isChecked
        }
    }
}
