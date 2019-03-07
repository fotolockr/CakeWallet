import UIKit
import FlexLayout

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


