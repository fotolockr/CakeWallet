import UIKit
import CakeWalletLib
import CakeWalletCore


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

final class NodesViewController: BaseViewController<NodesView>, UITableViewDelegate, UITableViewDataSource, StoreSubscriber {
    weak var nodesFlow: NodesFlow?
    let store: Store<ApplicationState>
    private(set) var nodes: [NodeCellItem]
    
    init(store: Store<ApplicationState>, nodesFlow: NodesFlow?) {
        self.nodesFlow = nodesFlow
        self.store = store
        nodes = []
        super.init()
    }

    override func configureBinds() {
        title = NSLocalizedString("nodes", comment: "")
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addNewNode))
        let resetButton = UIBarButtonItem(title: NSLocalizedString("reset", comment: ""), style: .plain, target: self, action: #selector(resetNodesList))
        navigationItem.rightBarButtonItems = [addButton, resetButton]
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
        updateAutoSwitch(isOn: state.settingsState.isAutoSwitchNodeOn)
//        if let node = state.settingsState.node {
//            updateCurrent(node: node)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nodeItem = nodes[indexPath.row]
        return tableView.dequeueReusableCell(withItem: nodeItem, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nodeItem = nodes[indexPath.row]
        askToChangeCurrentNode(to: nodeItem.node)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //fixme
        guard !nodes[indexPath.row].node.compare(with: store.state.settingsState.node!) else {
            return []
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("delete", comment: "")) { [weak self] (_, indexPath) in
            self?.removeNode(at: indexPath)
        }
        
        return [deleteAction]
    }
    
    func askToChangeCurrentNode(to node: NodeDescription) {
        let changeAction = CWAlertAction(title: NSLocalizedString("change", comment: "")) { [weak self] alert in
            self?.changeCurrentNode(to: node)
            alert.alertView?.dismiss(animated: true)
        }
        showInfo(title: String(format: NSLocalizedString("change_current_node_message", comment: ""), node.uri), actions: [changeAction, CWAlertAction.cancelAction])
    }
    
    func changeCurrentNode(to node: NodeDescription) {
        store.dispatch(
            SettingsActions.changeCurrentNode(to: node)
        )
    }
    
    private func updateNodes() {
        //fixme
        let dispatchGroup = DispatchGroup()
        
        self.nodes = NodesList.shared.values // fixme
            .map { NodeCellItem(node: $0, isCurrent: self.store.state.settingsState.node!.compare(with: $0)) }
        
        nodes.forEach { nodeCell in
            dispatchGroup.enter()
            nodeCell.node.isAble({ isAble in
                nodeCell.isAble = isAble
                dispatchGroup.leave()
            })
        }

        dispatchGroup.notify(queue: .main) {
            print("Updated")
            self.contentView.table.reloadData()
        }
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
    //fixme
    @objc
    private func resetNodesList() {
        let resetAction = CWAlertAction(title: NSLocalizedString("reset", comment: "")) { [weak self] action in
            do {
                try NodesList.shared.reset()
                self?.updateNodes()
                self?.changeCurrentNode(to: Configurations.defaultMoneroNode)
                action.alertView?.dismiss(animated: true)
            } catch {
                action.alertView?.dismiss(animated: true) {
                    
                    //                    self?.showError(error)
                }
            }
        }
        
        showInfo(title: NSLocalizedString("node_reset_settings_title", comment: ""), message: NSLocalizedString("nodes_list_reset_to_default_message", comment: ""), actions: [resetAction, CWAlertAction.cancelAction])
    }
    //fixme
    private func removeNode(at indexPath: IndexPath) {
        let removeAction = CWAlertAction(title: NSLocalizedString("remove", comment: "")) { [weak self] _ in
            do {
                try NodesList.shared.remove(at: indexPath.row)
                self?.updateNodes()
            } catch {
                //                self?.showError(error)
            }
        }
        showInfo(
            title: NSLocalizedString("delete_node", comment: ""),
            message: NSLocalizedString("delete_node_message", comment: ""),
            actions: [removeAction, CWAlertAction.cancelAction]
        )
    }
}
