import UIKit
import FlexLayout

final class AddressBookView: BaseFlexView {
    let table: UITableView
    
    required init() {
        table = UITableView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.define { flex in
            flex.addItem(table).height(100%).width(100%)
        }
    }
}
