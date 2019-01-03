import UIKit
import CakeWalletLib

final class TransactionUITableViewCell: FlexCell {
    let statusLabel: UILabel
    let dateLabel: UILabel
    let cryptoLabel: UILabel
    let fiatLabel: UILabel
    let topRow: UIView
    let bottomRow: UIView
    let _contentContainer: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        statusLabel = UILabel(fontSize: 14)
        dateLabel = UILabel.withLightText(fontSize: 12)
        cryptoLabel = UILabel(fontSize: 14)
        fiatLabel = UILabel.withLightText(fontSize: 12)
        topRow = UIView()
        bottomRow = UIView()
        _contentContainer = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
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
        
        contentView.flex.marginLeft(10).padding(UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)).direction(.row).define { flex in
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
            flex.height(22)
            flex.width(22)
        }
    }
    
    func configure(direction: TransactionDirection, date: Date, isPending: Bool, cryptoAmount: Amount, fiatAmount: String) {
        let color: UIColor
        let amountPrefix: String
        var status = ""
        
        if direction == .incoming {
            status = NSLocalizedString("receive", comment: "") // FIXME: Hardcoded value
            color = .greenMalachite
            amountPrefix = "+"
            imageView?.image = UIImage(named: "arrow_down_bg")?.resized(to: CGSize(width: 22, height: 22))
        } else {
            status = NSLocalizedString("sent", comment: "") // FIXME: Hardcoded value
            color = .wildDarkBlue
            amountPrefix = "-"
            imageView?.image = UIImage(named: "arrow_up_bg")?.resized(to: CGSize(width: 22, height: 22))
        }
        
        if isPending {
            status += " (" +  NSLocalizedString("pending", comment: "") + ")"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy, HH:mm"
        statusLabel.text = status
        cryptoLabel.text = "\(amountPrefix)\(cryptoAmount.formatted()) \(cryptoAmount.currency.formatted())"
        cryptoLabel.textColor = color
        dateLabel.text = dateFormatter.string(from: date)
        fiatLabel.text = fiatAmount
        
        statusLabel.flex.markDirty()
        cryptoLabel.flex.markDirty()
        dateLabel.flex.markDirty()
        fiatLabel.flex.markDirty()
        contentView.flex.layout()
    }
}

