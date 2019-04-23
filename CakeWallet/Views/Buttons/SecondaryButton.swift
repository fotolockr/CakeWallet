import UIKit

class SecondaryButton: Button {
    override func configureView() {
        super.configureView()
        backgroundColor = Theme.current.secondaryButton.background
        layer.applySketchShadow(color: UIColor(hex: 0x9bacc5), alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
    }
}
