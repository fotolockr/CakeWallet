import UIKit

extension UIView {
    func applyCardSketchShadow() {
        self.layer.applySketchShadow(color: UIColor(red: 000, green: 000, blue: 000, alpha: 0.1), alpha: 0.5, x: 0, y: 8, blur: 12, spread: -8)
    }
}

class CardView: BaseView {
    override func configureView() {
        super.configureView()
        
        applyCardSketchShadow()
        backgroundColor = Theme.current.card.background
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.cornerRadius = 12
    }
}
