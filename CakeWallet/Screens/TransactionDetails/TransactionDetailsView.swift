import UIKit
import FlexLayout

final class TransactionDetailsView: BaseFlexView {
    let cardView: CardView
    let table: UITableView
    
    required init() {
        cardView = CardView()
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.allowsSelection = false
        table.backgroundColor = .clear
    }
    
    
    override func configureConstraints() {
        rootFlexContainer.flex.padding(20).backgroundColor(.clear).define { flex in
            flex.addItem(table).width(100%).height(100%)
        }
    }
}
