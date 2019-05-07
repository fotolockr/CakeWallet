import UIKit
import FlexLayout

final class SubaddressesView: BaseFlexView {
    let table: UITableView
    let newSubaddressTextiField: CWTextField
    let newSubaddressButton: UIButton
    let newSubaddressContiner: UIView
    let cardView: UIView
    
    required init() {
        table = UITableView()
        newSubaddressTextiField = CWTextField(placeholder: NSLocalizedString("new_subaddress_label", comment: ""))
        newSubaddressButton = SecondaryButton(title: NSLocalizedString("add", comment: ""))
        newSubaddressContiner = UIView()
        cardView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear

//        newSubaddressButton.setTitleColor(.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = newSubaddressContiner.frame.size.width - newSubaddressButton.frame.size.width - 50
        newSubaddressTextiField.flex.width(width).layout()
        newSubaddressContiner.flex.layout()
    }
        
    override func configureConstraints() {
        newSubaddressContiner.flex.direction(.rowReverse).padding(20).justifyContent(.spaceBetween).alignItems(.center).width(100%).define { flex in
            flex.addItem(newSubaddressButton).height(35).backgroundColor(.whiteSmoke)
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
