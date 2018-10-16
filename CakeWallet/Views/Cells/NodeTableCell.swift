import UIKit

final class NodeTableCell: FlexCell {
    let addressLabel: UILabel
    let indicatorView: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        indicatorView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        addressLabel = UILabel(fontSize: 16)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        backgroundColor = .clear
        indicatorView.layer.masksToBounds = false
        indicatorView.layer.cornerRadius = 5
        contentView.layer.applySketchShadow(color: .wildDarkBlue, alpha: 0.25, x: 10, y: 3, blur: 13, spread: 2)
    }
    
    override func configureConstraints() {
        contentView.flex
            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
            .padding(0, 20, 0, 20)
            .height(50)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignSelf(.center)
            .define { flex in
                flex.addItem(addressLabel)
                flex.addItem(indicatorView).height(10).width(10).alignSelf(.center)
        }
    }
    
    func configure(address: String, isAble: Bool, isCurrent: Bool) {
        addressLabel.text = address
        addressLabel.flex.markDirty()
        indicatorView.backgroundColor = isAble ? .greenMalachite : .red
        contentView.backgroundColor = isCurrent ? .vividBlue : .white
        addressLabel.textColor = isCurrent ? .white : .black
        contentView.flex.layout()
    }
}

final class LangTableCcell: FlexCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .white
        backgroundColor = .clear
        contentView.layer.applySketchShadow(color: .wildDarkBlue, alpha: 0.25, x: 10, y: 3, blur: 13, spread: 2)
        textLabel?.font = UIFont.systemFont(ofSize: 14) //fixme
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        guard let textLabel = self.textLabel else {
            return
        }
        
        contentView.flex
            .margin(UIEdgeInsets(top: 7, left: 20, bottom: 0, right: 20))
            .padding(0, 20, 0, 20)
            .height(50)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignSelf(.center)
            .define { flex in
                flex.addItem(textLabel)
        }
    }
    
    func configure(lang: Languages, isCurrent: Bool) {
        textLabel?.text = lang.formatted()
        contentView.backgroundColor = isCurrent ? .vividBlue : .white
        textLabel?.textColor = isCurrent ? .white : .black
        contentView.flex.layout()
    }
}
