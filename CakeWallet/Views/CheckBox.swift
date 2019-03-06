import UIKit
import FlexLayout

class CheckBox: UIButton {
    static let defaultSize = CGSize(width: 25, height: 25)
    
    let checkedImage = UIImage(named: "checked")! as UIImage
    
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

class BoxCheck: BaseFlexView, UIGestureRecognizerDelegate {
    let wrapper: UIView

    var activeColor: UIColor = .red
    var isChecked: Bool = false {
        didSet {
            activeColor = isChecked ? .blue : .red
        }
    }
    
    required init() {
        wrapper = UIView()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        let UITapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPressAction))
        UITapRecognizer.delegate = self
        self.addGestureRecognizer(UITapRecognizer)
        
        print("configure view")
    }

    @objc
    func onPressAction() {
        isChecked = !isChecked
        self.wrapper.backgroundColor = .blue
    }
    
    override func configureConstraints() {
//        let backgroundColor = isChecked ? UIColor.red : UIColor.blue
        
        print(activeColor)
        
        rootFlexContainer.flex.define { flex in
            flex.addItem(wrapper).justifyContent(.center).alignItems(.center).width(25).height(25).backgroundColor(.red)
        }
    }
}

//UIView.animate(
//    withDuration: 0.6,
//    animations: {
//        self.button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
//},
//    completion: { _ in UIView.animate(withDuration: 0.6) {
//        self.button.transform = CGAffineTransform.identity
//        }}
//)
