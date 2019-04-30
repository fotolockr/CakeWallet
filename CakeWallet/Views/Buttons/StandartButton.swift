import UIKit

final class StandartButton: Button {
    override func configureView() {
        super.configureView()
        backgroundColor = .white
        setTitleColor(UIColor.spaceViolet, for: .normal)
    }
}
