import UIKit

extension UITableViewCell {
    private static let speparatorTag = 292
    
    func addSeparator(height: CGFloat = 1, x: CGFloat = 0, color: UIColor = .separatorGrey) {
        guard viewWithTag(UITableViewCell.speparatorTag) == nil else {
            return
        }
        
        let width = self.frame.size.width
        let y = self.frame.size.height - height
        let frame =  CGRect(x: x, y: y, width: width, height: height)
        addSeparator(frame: frame, color: color)
    }
    
    func addSeparator(frame: CGRect, color: UIColor = .separatorGrey) {
        guard viewWithTag(UITableViewCell.speparatorTag) == nil else {
            return
        }
        
        let separator = UIView(frame: frame)
        separator.backgroundColor = color
        separator.tag = UITableViewCell.speparatorTag
        addSubview(separator)
    }
    
    func removeSeparator() {
        guard let separator = viewWithTag(UITableViewCell.speparatorTag) else {
            return
        }
        
        separator.removeFromSuperview()
    }
}
