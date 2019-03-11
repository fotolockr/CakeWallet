import UIKit
import FlexLayout
import SwiftSVG

final class SplashView: BaseFlexView {
    let wrapper: UIView
    
    required init() {
        wrapper = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        let logo = UIView(SVGNamed: "cake_logo_svg") { (svgLayer) in
            svgLayer.resizeToFit(self.wrapper.bounds)
        }
        
        wrapper.flex.width(120).height(120).define{ flex in
            flex.addItem(logo)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(wrapper)
        }
    }
}
