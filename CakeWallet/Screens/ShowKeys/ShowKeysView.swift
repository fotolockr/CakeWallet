import UIKit
import FlexLayout

final class ShowKeysView: BaseFlexView {
    let cardView: CardView
    let table: UITableView
    
    required init() {
        cardView = CardView()
        table = UITableView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
//        isOpaque = true
//        backgroundColor = .clear
//        rootFlexContainer.backgroundColor = .clear
        table.tableFooterView = UIView()
        table.allowsSelection = false
        table.isScrollEnabled = false
    }
    
    override func configureConstraints() {
        cardView.flex.padding(20).define { flex in
            flex.addItem(table).grow(1).width(100%)
        }
        
        rootFlexContainer.flex.padding(20).define { flex in
            flex.addItem(cardView).grow(1).width(100%)
        }
    }
}
