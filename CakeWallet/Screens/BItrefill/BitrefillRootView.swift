import UIKit
import FlexLayout


final class BitrefillBaseView: BaseFlexView {
    let table: UITableView
    let loaderHolder: UIView
    
    required init() {
        table = UITableView()
        loaderHolder = UIView()
        table.tableFooterView = UIView()
        table.backgroundColor = Theme.current.container.background
        table.separatorStyle = .none
        super.init()
    }
    
    override func configureConstraints() {
        // TODO: show spinner
        let label = UILabel(text: "Fetching...")

        loaderHolder.flex
            .justifyContent(.center).alignItems(.center)
            .position(.absolute).top(20).left(0).bottom(0)
            .backgroundColor(Theme.current.container.background)
            .define { flex in
                flex.addItem(label)
        }
        
        rootFlexContainer.flex
            .backgroundColor(Theme.current.container.background)
            .paddingTop(20)
            
            .define { flex in
                flex.addItem(table).height(100%).width(100%)
                flex.addItem(loaderHolder).height(100%).width(100%)
        }
    }
}

