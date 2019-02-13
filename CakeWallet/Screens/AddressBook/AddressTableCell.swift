import UIKit

final class AddressTableCell: FlexCell {
    let nameLabel = UILabel(fontSize: 15)
    let typeLabel = UILabel(fontSize: 12)
    let leftViewWrapper = UIView()
    let typeViewWrapper = UIView()
    let typeView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        backgroundColor = .clear
        contentView.layer.applySketchShadow(color: .wildDarkBlue, alpha: 0.25, x: 10, y: 3, blur: 13, spread: 2)
        selectionStyle = .none
        
        typeLabel.textColor = .white
        typeView.layer.borderWidth = 1
        typeView.layer.cornerRadius = 8
        typeView.layer.masksToBounds = true
    }
    
    override func configureConstraints() {
        contentView.flex
            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
            .padding(5, 10, 5, 10)
            .height(50)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
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
                        .marginRight(14)
                        .padding(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
                        .addItem(typeLabel)
                    wrapperFlex.addItem(nameLabel)
                })
        }
    }
    
    func configure(name: String, type: String, color: UIColor) {
        nameLabel.text = name
        typeLabel.text = type
        typeLabel.textColor = color
        typeView.layer.borderColor = color.cgColor
        nameLabel.flex.markDirty()
        typeLabel.flex.markDirty()
        contentView.flex.layout()
    }
}
