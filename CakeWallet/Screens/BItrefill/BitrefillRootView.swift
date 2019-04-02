import UIKit
import FlexLayout


final class BitrefillBaseView: BaseFlexView {
    let table: UITableView
    
    required init() {
        table = UITableView()
        table.tableFooterView = UIView()
        table.backgroundColor = Theme.current.container.background
        table.separatorStyle = .none
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .backgroundColor(Theme.current.container.background)
            .paddingTop(20)
            .define { flex in
                flex.addItem(table).height(100%).width(100%)
        }
    }
}

