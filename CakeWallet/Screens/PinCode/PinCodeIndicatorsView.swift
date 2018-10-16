import UIKit
import FlexLayout

final class PinCodeIndicatorsView: BaseFlexView {
    private static let size = CGSize(width: 40, height: 40)
    let stackView: UIStackView
    private(set) var pinCodeIndicatorViews: [PinCodeIndicatorView]
    
    init(length: Int = 4) {
        var indicators = [PinCodeIndicatorView]()
        
        for i in 0..<length {
            indicators[i] = PinCodeIndicatorView()
        }
        
        pinCodeIndicatorViews = indicators
        stackView = UIStackView(arrangedSubviews: pinCodeIndicatorViews)
        super.init()
    }
    
    required init() {
        pinCodeIndicatorViews = [PinCodeIndicatorView(), PinCodeIndicatorView(), PinCodeIndicatorView(), PinCodeIndicatorView()]
        stackView = UIStackView(arrangedSubviews: pinCodeIndicatorViews)
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.direction(.row).justifyContent(.center).width(100%).define { flex in
            self.pinCodeIndicatorViews.forEach({ view in
                flex.addItem(view).size(PinCodeIndicatorsView.size).marginRight(10)
            })
        }
    }
    
    func changeIndicators(count: Int = 4) {
        pinCodeIndicatorViews.forEach({
            $0.removeFromSuperview()
        })
        
        pinCodeIndicatorViews = [PinCodeIndicatorView]()
        
        for _ in 0..<count {
            pinCodeIndicatorViews.append(PinCodeIndicatorView())
        }
        
        configureConstraints()
        setNeedsLayout()
    }
}
