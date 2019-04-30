import UIKit

extension UITableViewCell {
    private static let speparatorTag = 292
    
    func addSeparator() {
        guard viewWithTag(UITableViewCell.speparatorTag) == nil else {
            return
        }
        
        let width = frame.size.width
        let height = 1 as CGFloat
        let y = frame.size.height - height
        let x = 0 as CGFloat
        let separator = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        separator.backgroundColor = .separatorGrey
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
