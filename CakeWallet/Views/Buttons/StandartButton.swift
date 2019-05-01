import UIKit

final class StandartButton: Button {
    override func configureView() {
        super.configureView()
        applyCardSketchShadow()
        backgroundColor = .white
        setTitleColor(UIColor.spaceViolet, for: .normal)
    }
}
