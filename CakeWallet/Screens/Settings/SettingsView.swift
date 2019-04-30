import UIKit
import FlexLayout


final class SettingsView: BaseFlexView {
    let table: UITableView
    let footerLabel: UILabel
    
    required init() {
        table = UITableView()
        footerLabel = UILabel(fontSize: 12)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        footerLabel.textColor = .wildDarkBlue
        footerLabel.frame = CGRect(
            origin: CGPoint(x: 20, y: 0),
            size: CGSize(width: 50, height: 50)
        )
        table.tableFooterView = footerLabel
        backgroundColor = .lightCream
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .backgroundColor(.lightCream)
            .define { flex in
                flex.addItem(table).height(100%).width(100%)
        }
    }
}
