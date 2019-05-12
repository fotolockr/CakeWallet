import UIKit

final class StandartButton: Button {
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        setTitleColor(UIColor.spaceViolet, for: .normal)
    }
}
