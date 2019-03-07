import UIKit
import FlexLayout

class BoxCheck: UIButton {
    static let defaultSize = CGSize(width: 25, height: 25)
    
    let checkedImage = UIImage(named: "checked")! as UIImage
    
    var isChecked: Bool = false {
        didSet{
            let image = isChecked ? checkedImage : nil
            self.setImage(image, for: UIControlState.normal)
        }
    }
    
    private let size: CGSize
    
    required init(size: CGSize = BoxCheck.defaultSize) {
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




class CheckBox: BaseFlexView, UIGestureRecognizerDelegate {
    let wrapper: UIView
    let iconImage: UIImageView

    var isChecked: Bool = false {
        didSet {
            iconImage.isHidden = !isChecked
            
            UIView.animate(
                withDuration: 0.1,
                animations: { [weak self] in
                    self?.iconImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                },
                completion: { _ in UIView.animate(withDuration: 0.1) {
                    self.iconImage.transform = CGAffineTransform.identity
                }}
            )
        }
    }
    
    required init() {
        wrapper = UIView()
        iconImage = UIImageView(image: UIImage(named: "checked"))
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        let UITapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPressAction))
        UITapRecognizer.delegate = self
        self.addGestureRecognizer(UITapRecognizer)
        
        wrapper.layer.borderWidth = 1
        wrapper.layer.cornerRadius = 8
        wrapper.layer.borderColor = UIColor.wildDarkBlue.cgColor
        
        iconImage.isHidden = true
    }

    @objc
    func onPressAction() {
        isChecked = !isChecked
    }
    
    override func configureConstraints() {
        wrapper.flex
            .justifyContent(.center)
            .alignItems(.center)
            .width(25)
            .height(25).define{ flex in
                flex.addItem(iconImage)
        }
        
        rootFlexContainer.flex.define { flex in
            flex.addItem(wrapper)
        }
    }
}


