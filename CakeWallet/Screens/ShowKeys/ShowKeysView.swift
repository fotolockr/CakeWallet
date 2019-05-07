import UIKit
import FlexLayout

final class ShowKeysView: BaseFlexView {
    let table: UITableView
    
    required init() {
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.allowsSelection = false
        table.isScrollEnabled = false
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.padding(20).define { flex in
            flex.addItem(table).grow(1).width(100%)
        }
    }
}
