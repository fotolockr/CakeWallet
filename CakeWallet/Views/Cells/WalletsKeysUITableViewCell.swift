import UIKit

final class WalletsKeysUITableViewCell: FlexCell {
    let titleLabel: UILabel
    let valueLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        titleLabel = UILabel(fontSize: 14)
        valueLabel = UILabel.withLightText(fontSize: 14)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.numberOfLines = 0
    }
    
    override func configureConstraints() {
        contentView.flex.padding(10, 0, 10, 0).define { flex in
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
