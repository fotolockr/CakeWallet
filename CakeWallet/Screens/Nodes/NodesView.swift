import UIKit
import FlexLayout

final class NodesView: BaseFlexView {
    let table: UITableView
    let autoNodeSwitchContainer: UIView
    let autoNodeSwitchLabel: UILabel
    let autoNodeSwitch: SwitchView
    
    required init() {
        table = UITableView()
        autoNodeSwitchContainer = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 60)))
        autoNodeSwitch = SwitchView()
        autoNodeSwitchLabel = UILabel()
        autoNodeSwitchLabel.font = applyFont(ofSize: 16)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        table.tableFooterView = UIView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.rootFlexContainer.frame.size.height - 60
        table.flex.height(height).width(100%).markDirty()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    override func configureConstraints() {
        autoNodeSwitchContainer.flex
            .direction(.row).backgroundColor(.lightCream)
            .padding(0, 20, 0, 20)
            .justifyContent(.spaceBetween).alignItems(.center)
            .height(56).define { flex in
                flex.addItem(autoNodeSwitchLabel)
                flex.addItem(autoNodeSwitch).width(55).height(33)
        }
        
        rootFlexContainer.flex
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(autoNodeSwitchContainer).width(100%).marginTop(5)
                flex.addItem(table).width(100%).marginTop(15)
        }
    }
}
