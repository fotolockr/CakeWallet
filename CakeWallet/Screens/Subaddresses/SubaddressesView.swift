import UIKit
import FlexLayout

final class SubaddressesView: BaseFlexView {
    let table: UITableView
    let newSubaddressTextiField: TextField
    let newSubaddressButton: UIButton
    let newSubaddressContiner: UIView
    let cardView: UIView
    
    required init() {
        table = UITableView()
        newSubaddressButton = UIButton()
        newSubaddressTextiField = TextField(placeholder: NSLocalizedString("new_subaddress_label", comment: ""), isTransparent: false)
    
        newSubaddressButton.backgroundColor = Theme.current.container.background
        newSubaddressButton.imageView?.backgroundColor = Theme.current.container.background
        newSubaddressButton.setImage(UIImage(named: "add_icon_purple")?.resized(to: CGSize(width: 30, height: 30)), for: .normal)
        
        newSubaddressContiner = UIView()
        cardView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        newSubaddressTextiField.textField.font = applyFont(ofSize: 17)
        
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = newSubaddressContiner.frame.size.width - newSubaddressButton.frame.size.width - 35
        
        newSubaddressTextiField.flex.width(width).layout()
        newSubaddressContiner.flex.layout()
    }
        
    override func configureConstraints() {
        newSubaddressContiner.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .width(100%)
            .backgroundColor(Theme.current.container.background)
            .define { flex in
                flex.addItem(newSubaddressTextiField).height(40)
                flex.addItem(newSubaddressButton).height(35).backgroundColor(.whiteSmoke)
        }
        
        cardView.flex
            .paddingTop(10)
            .define { flex in
                flex.addItem(newSubaddressContiner).width(100%)
                flex.addItem(table).width(100%).grow(1)
        }
        
        rootFlexContainer.flex.padding(20).alignItems(.start).define { flex in
            flex.addItem(cardView).grow(1).width(100%)
        }
    }
}
