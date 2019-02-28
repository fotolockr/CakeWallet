import UIKit

class CheckBox: UIButton {
    static let defaultSize = CGSize(width: 25, height: 25)
    
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "close_symbol")! as UIImage
    
    var isChecked: Bool = false {
        didSet{
            let image = isChecked ? checkedImage : nil
            self.setImage(image, for: UIControlState.normal)
        }
    }
    
    private let size: CGSize
    
    required init(size: CGSize = CheckBox.defaultSize) {
        self.size = size
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selfResize()
    }
    
    override func configureView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.wildDarkBlue.cgColor
        layer.cornerRadius = 8
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        imageEdgeInsets = UIEdgeInsetsMake(1, 6, 1, 6)
        
        addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        super.configureView()
    }
    
    private func selfResize() {
        frame = CGRect(origin: frame.origin, size: size)
    }
    
    @objc
    func buttonClicked() {
        isChecked = !isChecked
    }
}
