import UIKit

final class SwitchView: BaseView {
    let indicatorView: UIView
    let indicatorImageView: UIImageView
    var isOn: Bool {
        didSet {
            onValueChange(withAnimation: true)
            onChangeHandler?(isOn)
        }
    }
    var onChangeHandler: ((Bool) -> Void)?
    
    convenience init(initialValue: Bool = false) {
        self.init()
        isOn = initialValue
    }
    
    required init() {
        indicatorView = UIView()
        indicatorImageView = UIImageView()
        isOn = false
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 40)))
    }
    
    override func configureView() {
        super.configureView()
        onValueChange(withAnimation: false)
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapHandler))
        backgroundColor = UIColor(red: 228, green: 231, blue: 240)
        layer.masksToBounds = false
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightBlueGrey.cgColor
        
        indicatorImageView.layer.masksToBounds = false
        indicatorView.addSubview(indicatorImageView)
        addGestureRecognizer(onTapGesture)
        addSubview(indicatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height * 0.4
        indicatorView.layer.cornerRadius = indicatorImageView.frame.size.height * 0.5
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        onValueChange(withAnimation: false)
    }
    
    @objc
    private func onTapHandler() {
        isOn = !isOn
    }
    
    private func onValueChange(withAnimation isAnimated: Bool) {
        let indicatorFrame: CGRect
        let image: UIImage?
        let backgroundColor: UIColor
        let height = frame.size.height - 10
        let indicatorSize = CGSize(width: height, height: height)
        
        if isOn {
            image = UIImage(named: "check_mark")
            backgroundColor = .vividBlue
            let x = frame.size.width - indicatorSize.width - 5
            indicatorFrame = CGRect(origin: CGPoint(x: x, y: 5), size: indicatorSize)
        } else {
            image = UIImage(named: "close_icon_white")
            backgroundColor = .wildDarkBlue
            indicatorFrame = CGRect(origin: CGPoint(x: 5, y: 5), size: indicatorSize)
        }
        
        indicatorImageView.image = image
        indicatorImageView.frame = CGRect(origin: CGPoint(x: 7, y: 7), size: CGSize(width: 10, height: 10))
        indicatorView.backgroundColor = backgroundColor
        
        if isAnimated {
            UIView.animate(withDuration: 0.5) {
                self.indicatorView.frame = indicatorFrame
            }
        } else {
            self.indicatorView.frame = indicatorFrame
        }
    }
}
