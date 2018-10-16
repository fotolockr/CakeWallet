import UIKit
import CakeWalletCore
import CWMonero

final class SubaddressCell: FlexCell {
    func setup(label: String, address: String) {
        textLabel?.text = label
    }
}

extension Subaddress: CellItem {
    func setup(cell: SubaddressCell) {
        cell.setup(label: label, address: address)
    }
}

final class SubaddressesViewController: BaseViewController<SubaddressesView>, UITableViewDataSource, UITableViewDelegate, StoreSubscriber {
    let store: Store<ApplicationState>
    var onSelectedHandler: ((Subaddress) -> Void)?
    var subaddresses: [Subaddress] {
        didSet {
            contentView.table.reloadData()
        }
    }
    
    init(store: Store<ApplicationState>) {
        self.store = store
        subaddresses = []
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("subaddresses", comment: "")
        contentView.table.dataSource = self
        contentView.table.delegate = self
        contentView.table.register(items: [Subaddress.self])
        contentView.newSubaddressButton.addTarget(self, action: #selector(addSubaddressAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [\ApplicationState.subaddressesState])
        store.dispatch(
            SubaddressesActions.update
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        subaddresses = state.subaddressesState.subaddresses
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subaddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = subaddresses[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard subaddresses.count > indexPath.row else {
            return
        }
        
        let sub = subaddresses[indexPath.row]
        onSelectedHandler?(sub)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    private func addSubaddressAction() {
        guard let label = contentView.newSubaddressTextiField.text else {
            return
        }
                
        store.dispatch(
            SubaddressesActions.addNew(
                withLabel: label,
                handler: { [weak self] in
                    DispatchQueue.main.async {
                        self?.contentView.newSubaddressTextiField.text = nil
                    }
            })
        )
    }
}
