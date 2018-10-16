import UIKit

final class TransactionDetailsCell: FlexCell {
    let titleLabel: UILabel
    let valueLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(fontSize: 14)
        valueLabel = UILabel.withLightText(fontSize: 14)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.backgroundColor = .white
        titleLabel.numberOfLines = 0
        valueLabel.numberOfLines = 0
    }
    
    override func configureConstraints() {
        contentView.flex.padding(10, 20, 10, 20).define { flex in
            flex.addItem(titleLabel)
            flex.addItem(valueLabel).marginTop(5)
        }
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        titleLabel.flex.markDirty()
        valueLabel.flex.markDirty()
        layout()
    }
}
