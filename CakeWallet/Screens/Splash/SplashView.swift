import UIKit
import FlexLayout

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
        let logo = UIImageView(image: UIImage(named: "cake_logo_image")?.resized(to: CGSize(width: 120, height: 120)))
        
        wrapper.flex.define{ flex in
            flex.addItem(logo)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(wrapper)
        }
    }
}
