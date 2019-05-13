import UIKit
import CakeWalletLib
import CakeWalletCore
import SwipeCellKit


let nodesQueue = DispatchQueue(label: "app.cakewallet.nodes-queue", qos: .default, attributes: DispatchQueue.Attributes.concurrent)

final class NodeCellItem: CellItem {
    let node: NodeDescription
    let isCurrent: Bool
    var isAble: Bool
    
    init(node: NodeDescription, isCurrent: Bool, isAble: Bool = false) {
        self.node = node
        self.isCurrent = isCurrent
        self.isAble = isAble
    }
    
    func setup(cell: NodeTableCell) {
        cell.configure(address: node.uri, isAble: isAble, isCurrent: isCurrent)
    }
}


final class NodesViewController: BaseViewController<NodesView>, UITableViewDelegate, UITableViewDataSource, StoreSubscriber, SwipeTableViewCellDelegate {
    weak var nodesFlow: NodesFlow?
    let store: Store<ApplicationState>
    private(set) var nodes: [NodeCellItem]
    private var currentNode: NodeDescription? {
        didSet {
            if oldValue != nil {
                updateNodes()
            }
        }
    }
    
    init(store: Store<ApplicationState>, nodesFlow: NodesFlow?) {
        self.nodesFlow = nodesFlow
        self.store = store
        nodes = []
        super.init()
    }

    override func configureBinds() {
        title = NSLocalizedString("nodes", comment: "")
        
        let addButton = makeIconedNavigationButton(iconName: "add_icon_purple", target: self, action: #selector(addNewNode))
        let resetButton = makeTitledNavigationButton(title: NSLocalizedString("reset", comment: ""), target: self, action: #selector(resetNodesList))
        
        navigationItem.rightBarButtonItems = [addButton, resetButton]
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [NodeCellItem.self])
        contentView.autoNodeSwitchLabel.text = NSLocalizedString("auto_switch_node", comment: "")
        contentView.autoNodeSwitch.onChangeHandler = { [weak store] isOn in
            store?.dispatch(
                SettingsActions.changeAutoSwitchNodes(isOn: isOn)
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [\ApplicationState.settingsState])
        updateNodes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func onStateChange(_ state: ApplicationState) {
        currentNode = state.settingsState.node
        updateAutoSwitch(isOn: state.settingsState.isAutoSwitchNodeOn)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NodeTableCell.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nodeItem = nodes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: nodeItem, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nodeItem = nodes[indexPath.row]
        askToChangeCurrentNode(to: nodeItem.node)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let selectedNode = nodes[indexPath.row].node
        
        guard
            let currentNode = store.state.settingsState.node,
            !selectedNode.compare(with: currentNode) else {
                return nil
        }
  
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            self?.removeNode(at: indexPath)
        }
        deleteAction.image = UIImage(named: "trash_icon")?.resized(to: CGSize(width: 23, height: 23))
        
        return [deleteAction]
    }
    
    func askToChangeCurrentNode(to node: NodeDescription) {
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let changeAction = UIAlertAction(title: NSLocalizedString("change", comment: ""), style: .default) { [weak self] _ in
            self?.changeCurrentNode(to: node)
        }
        
        showInfoAlert(title: String(format: NSLocalizedString("change_current_node_message", comment: ""), node.uri), actions: [changeAction, cancelAction])
    }
    
    func changeCurrentNode(to node: NodeDescription) {
        store.dispatch(
            SettingsActions.changeCurrentNode(to: node)
        )
    }
    
    private func updateNodes() {
        nodes = NodesList.shared.values // fixme
            .map { NodeCellItem(node: $0, isCurrent: self.store.state.settingsState.node!.compare(with: $0)) }
        
        nodes.forEach { nodeCell in
            nodeCell.node.isAble({ isAble in
                nodeCell.isAble = isAble
                
                DispatchQueue.main.async {
                    self.contentView.table.reloadData()
                }
            })
        }
        
        contentView.table.reloadData()
    }
    
    private func updateAutoSwitch(isOn: Bool) {
        if contentView.autoNodeSwitch.isOn != isOn {
            contentView.autoNodeSwitch.isOn = isOn
        }
    }
    
    private func updateCurrent(node: NodeDescription) {
        nodes = self.nodes.map { NodeCellItem(node: $0.node, isCurrent: $0.node.compare(with: node)) }
        contentView.table.reloadData()
    }
    
    @objc
    private func addNewNode() {
        nodesFlow?.change(route: .new)
    }
    
    @objc
    private func resetNodesList() {
        let resetAction = UIAlertAction(title: NSLocalizedString("reset", comment: ""), style: .default) { [weak self] _ in
            do {
                try NodesList.shared.reset()
                self?.updateNodes()
                self?.changeCurrentNode(to: Configurations.defaultMoneroNode)
                
            } catch {
              
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        showInfoAlert(
            title: NSLocalizedString("node_reset_settings_title", comment: ""),
            message: NSLocalizedString("nodes_list_reset_to_default_message", comment: ""),
            actions: [resetAction, cancelAction]
        )
    }
    
    private func removeNode(at indexPath: IndexPath) {
        let removeAction = UIAlertAction(title: NSLocalizedString("remove", comment: ""), style: .default) { [weak self] _ in
            do {
                try NodesList.shared.remove(at: indexPath.row)
                self?.updateNodes()
            } catch {
                self?.showErrorAlert(error: error)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        showInfoAlert(
            title: NSLocalizedString("delete_node", comment: ""),
            message: NSLocalizedString("delete_node_message", comment: ""),
            actions: [removeAction, cancelAction]
        )
    }
}
