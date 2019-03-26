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
//        isOpaque = true
//        backgroundColor = .clear
//        rootFlexContainer.backgroundColor = .clear
        table.tableFooterView = UIView()
        table.allowsSelection = false
        table.backgroundColor = .clear
//        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 20)
//        table.contentOffset = CGPoint(x: 20, y: 10)
//        table.isScrollEnabled = false
//        table.bounces = false
//        table.estimatedRowHeight = 0
        backgroundColor = .clear
        isOpaque = false
    }
    
    override func configureConstraints() {
//        cardView.flex.padding(20).define { flex in
//            flex.addItem(table).width(100%)
//        }
        
        rootFlexContainer.flex.padding(20).backgroundColor(.clear).define { flex in
//            flex.addItem(cardView).width(100%)
            flex.addItem(table).width(100%).height(100%) //.padding(20)
        }
    }
}
