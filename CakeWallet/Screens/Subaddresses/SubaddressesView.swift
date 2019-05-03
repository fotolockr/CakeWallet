import UIKit
import FlexLayout

final class SubaddressesView: BaseFlexView {
    let table: UITableView
    let newSubaddressTextiField: TextField
    let newSubaddressButton: UIButton
    let newSubaddressContiner: UIView
    let cardView: CardView
    
    required init() {
        table = UITableView()
        newSubaddressTextiField = TextField(placeholder: NSLocalizedString("new_subaddress_label", comment: ""))
        newSubaddressButton = PrimaryButton(title: NSLocalizedString("add", comment: ""))
        newSubaddressContiner = UIView()
        cardView = CardView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = newSubaddressContiner.frame.size.width - newSubaddressButton.frame.size.width - 50
        newSubaddressTextiField.flex.width(width).layout()
        newSubaddressContiner.flex.layout()
    }
        
    override func configureConstraints() {
        newSubaddressContiner.flex.direction(.rowReverse).padding(20).justifyContent(.spaceBetween).alignItems(.center).width(100%).define { flex in
            flex.addItem(newSubaddressButton).height(35)
            flex.addItem(newSubaddressTextiField).height(50)
        }
        
        cardView.flex.define { flex in
            flex.addItem(newSubaddressContiner).width(100%)
            flex.addItem(table).width(100%).grow(1)
        }
        
        rootFlexContainer.flex.padding(20).alignItems(.start).define { flex in
            flex.addItem(cardView).grow(1).width(100%)
        }
    }
}
