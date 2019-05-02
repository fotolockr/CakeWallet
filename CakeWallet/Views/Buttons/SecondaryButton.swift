import UIKit

class SecondaryButton: Button {
    override func configureView() {
        super.configureView()
        backgroundColor = Theme.current.secondaryButton.background
        layer.borderWidth = 0.75
        layer.borderColor = UIColor.grayBorder.cgColor
    }
}
