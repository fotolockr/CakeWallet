import UIKit

final class PrimaryButton: Button {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.applySketchShadow(color: UIColor(hex: 0xdfd0ff), alpha: 0.34, x: 0, y: 11, blur: 20, spread: -6)
    }
}
