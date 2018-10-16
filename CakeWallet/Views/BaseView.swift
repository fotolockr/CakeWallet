import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureConstraints()
//        setNeedsLayout()
//        layoutIfNeeded()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = Theme.current.container.background
    }
}

extension UIView {
    @objc
    func configureView() {}
    @objc
    func configureConstraints() {}
}
