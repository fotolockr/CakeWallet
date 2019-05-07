import UIKit
import FlexLayout

final class AccountsView: BaseFlexView {
    let table: UITableView
    let newSubaddressTextiField: CWTextField
    let newSubaddressButton: UIButton
    let newSubaddressContiner: UIView
    let cardView: UIView
    
    required init() {
        table = UITableView()
        table.separatorStyle = .none
        newSubaddressButton = UIButton()
        newSubaddressTextiField = CWTextField(placeholder: NSLocalizedString("new_account_label", comment: ""))
        
        newSubaddressButton.backgroundColor = Theme.current.container.background
        newSubaddressButton.imageView?.backgroundColor = Theme.current.container.background
        newSubaddressButton.setImage(UIImage(named: "add_icon_purple")?.resized(to: CGSize(width: 30, height: 30)), for: .normal)
        
        newSubaddressContiner = UIView()
        cardView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        newSubaddressTextiField.font = applyFont(ofSize: 17)
        
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        
        //        newSubaddressButton.setTitleColor(.white, for: .normal)
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
                //                flex.addItem(newSubaddressContiner).width(100%)
                flex.addItem(table).width(100%).grow(1)
        }
        
        rootFlexContainer.flex.alignItems(.start).define { flex in
            flex.addItem(cardView).grow(1).width(100%)
        }
    }
}
