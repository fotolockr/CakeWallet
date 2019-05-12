import UIKit
import CakeWalletLib

final class TransactionUITableViewCell: FlexCell {
    static let height = 70 as CGFloat
    let statusLabel: UILabel
    let dateLabel: UILabel
    let cryptoLabel: UILabel
    let fiatLabel: UILabel
    let topRow: UIView
    let bottomRow: UIView
    let _contentContainer: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        statusLabel = UILabel()
        statusLabel.font = applyFont(ofSize: 14, weight: .semibold)
        
        dateLabel = UILabel.withLightText(fontSize: 12)
        dateLabel.font = applyFont(ofSize: 12)
        
        cryptoLabel = UILabel(fontSize: 14)
        cryptoLabel.font = applyFont(ofSize: 14)
        cryptoLabel.textColor = .black
        
        fiatLabel = UILabel.withLightText(fontSize: 12)
        fiatLabel.font = applyFont(ofSize: 12)
        
        topRow = UIView()
        bottomRow = UIView()
        _contentContainer = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        layoutMargins = .zero
        contentView.backgroundColor = .white
        backgroundColor = .white
    }
    
    override func configureConstraints() {
        topRow.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(statusLabel)
            flex.addItem(cryptoLabel)
        }
        
        bottomRow.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(dateLabel)
            flex.addItem(fiatLabel)
        }

        contentView.flex.direction(.row).padding(UIEdgeInsets(top: 14, left: 20, bottom: 0, right: 10)).alignItems(.center).define { flex in
            if let imageView = imageView {
                flex.addItem(imageView)
            }
            
            flex.addItem(_contentContainer).margin(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)).grow(1)
        }
        
        _contentContainer.flex.define { flex in
            flex.addItem(topRow).marginRight(10)
            flex.addItem(bottomRow).marginRight(10).marginTop(5)
        }
        
        imageView?.flex.define { flex in
            flex.height(26)
            flex.width(26)
        }
    }
    
    func configure(direction: TransactionDirection, date: Date, isPending: Bool, cryptoAmount: Amount, fiatAmount: String) {
        let color: UIColor
        var status = ""
        
        if direction == .incoming {
            status = NSLocalizedString("receive", comment: "") // FIXME: Hardcoded value
            color = .black
            imageView?.image = UIImage(named: "arrow_down_green_icon")?.resized(to: CGSize(width: 26, height: 26))
        } else {
            status = NSLocalizedString("sent", comment: "") // FIXME: Hardcoded value
            color = .black
            imageView?.image = UIImage(named: "arrow_top_purple_icon")?.resized(to: CGSize(width: 26, height: 26))
        }
        
        if isPending {
            status += " (" +  NSLocalizedString("pending", comment: "") + ")"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy, HH:mm"
        statusLabel.text = status
        cryptoLabel.text = "\(cryptoAmount.formatted()) \(cryptoAmount.currency.formatted())"
        cryptoLabel.textColor = color
        dateLabel.text = dateFormatter.string(from: date)
        fiatLabel.text = fiatAmount
        
        statusLabel.flex.markDirty()
        cryptoLabel.flex.markDirty()
        dateLabel.flex.markDirty()
        fiatLabel.flex.markDirty()
        contentView.flex.layout()
    }
    
    func addSeparator() {
        let height = 1 as CGFloat
        let y = frame.size.height - height
        let leftOffset = 20 as CGFloat
        let rightOffset = 20 as CGFloat
        let width = frame.size.width - leftOffset - rightOffset
        let color = UIColor(red: 248, green: 250, blue: 253)
        addSeparator(frame: CGRect(x: leftOffset, y: y, width: width, height: height), color: color)
    }
}

