import UIKit
import PinLayout
import FlexLayout

class BaseFlexView: BaseView {
    let rootFlexContainer: UIView
    
    override init(frame: CGRect) {
        rootFlexContainer = UIView()
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        rootFlexContainer = UIView()
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all(pin.safeArea)
        rootFlexContainer.flex.layout()
    }
    
    override func configureView() {
        super.configureView()
        rootFlexContainer.flex.backgroundColor(Theme.current.container.background)
        addSubview(rootFlexContainer)
    }
}
