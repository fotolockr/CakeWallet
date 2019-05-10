import UIKit

extension UITableViewCell {
    func isCurrent(_ isCurrent: Bool) {
        let color: UIColor = isCurrent ? .purpleyLight : .white
        contentView.backgroundColor = color
        backgroundColor = color
    }
}
