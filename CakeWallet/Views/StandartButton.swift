import UIKit

final class StandartButton: Button {
    override func configureView() {
        super.configureView()
        backgroundColor = .white
        setTitleColor(UIColor.spaceViolet, for: .normal)
        layer.applySketchShadow(color: UIColor.wildDarkBlue, alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
    }
}
