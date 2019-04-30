import UIKit
import FlexLayout


final class AddressTableCell: FlexCell {
    static let height = 56 as CGFloat
    let nameLabel = UILabel()
    let typeLabel = UILabel()
    let leftViewWrapper = UIView()
    let typeViewWrapper = UIView()
    let typeView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white
        backgroundColor = .clear
        selectionStyle = .none
        
        nameLabel.font = applyFont(ofSize: 16)
        typeLabel.font = applyFont(ofSize: 12, weight: .bold)
        
        typeLabel.textColor = .white
        typeView.layer.cornerRadius = 8
        typeView.layer.masksToBounds = true
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        contentView.flex
            .direction(.row).justifyContent(.spaceBetween).alignItems(.center)
            .height(AddressTableCell.height).width(100%)
            .marginTop(15).padding(5, 15, 5, 15)
            .define { flex in
                flex.addItem(leftViewWrapper).define({ wrapperFlex in
                    wrapperFlex
                        .direction(.row)
                        .justifyContent(.spaceBetween)
                        .alignItems(.center)
                        .addItem(typeViewWrapper)
                        .width(90)
                        .alignItems(.center)
                        .addItem(typeView)
                        .marginRight(15)
                        .padding(UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15))
                        .addItem(typeLabel)
                    wrapperFlex.addItem(nameLabel)
                })
        }
    }
    
    func configure(name: String, type: String, backgroundColor: UIColor, textColor: UIColor) {
        nameLabel.text = name
        typeLabel.text = type
        typeView.backgroundColor = backgroundColor
        typeLabel.textColor = textColor
        nameLabel.flex.markDirty()
        typeLabel.flex.markDirty()
        contentView.flex.layout()
    }
}
