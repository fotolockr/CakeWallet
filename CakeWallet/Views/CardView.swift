import UIKit

class CardView: BaseView {
    override func configureView() {
        super.configureView()
        layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.16, x: 0, y: 16, blur: 46, spread: -5)
        backgroundColor = Theme.current.card.background
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.cornerRadius = frame.size.width * 0.05
    }
}
