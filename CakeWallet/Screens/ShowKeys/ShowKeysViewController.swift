import UIKit
import CakeWalletLib
import CakeWalletCore
import CWMonero

enum WalletsKeysRows: CakeWalletLib.Stringify {
    case publicView, privateView, publicSpend, privateSpend
    
    func string() -> String {
        switch self {
        case .publicView:
            return NSLocalizedString("view_key_public", comment: "")
        case .privateView:
            return NSLocalizedString("view_key_(private)", comment: "")
        case .publicSpend:
            return NSLocalizedString("spend_key_public", comment: "")
        case .privateSpend:
            return NSLocalizedString("spend_key_(private)", comment: "")
        }
    }
}

struct WalletKeysCellItem: CellItem {
    let row: WalletsKeysRows
    let key: String
    
    func setup(cell: WalletsKeysUITableViewCell) {
        cell.configure(title: row.string() + ":", value: key)
    }
}

final class ShowKeysViewController: BaseViewController<ShowKeysView>, UITableViewDataSource, UITableViewDelegate {
    private(set) var items: [WalletKeysCellItem]
    private let store: Store<ApplicationState>
    
    init(store: Store<ApplicationState>) {
        self.store = store
        items = []
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("wallet_keys", comment: "")
        contentView.table.dataSource = self
        contentView.table.delegate = self
        contentView.table.register(items: [WalletKeysCellItem.self])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let doneButton = StandartButton.init(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 12, height: 12)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 37, height: 37))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        
        if let keys = store.state.walletState.walletKeys {
            updateKeys(keys)
        }
        
        store.dispatch(
            WalletActions.fetchWalletKeys
        )
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if (action == #selector(UIResponderStandardEditActions.copy(_:))) {
            return true
        }
        
        return false
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let item = items[indexPath.row]
        UIPasteboard.general.string = item.key
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    private func updateKeys(_ walletKeys: WalletKeys) {
        if let keys = walletKeys as? MoneroWalletKeys {
            items = [
                WalletKeysCellItem(row: .publicView, key: keys.viewKey.pub),
                WalletKeysCellItem(row: .privateView, key: keys.viewKey.sec),
                WalletKeysCellItem(row: .publicSpend, key: keys.spendKey.pub),
                WalletKeysCellItem(row: .privateSpend, key: keys.spendKey.sec)
            ]
        }
        contentView.table.reloadData()
    }
}
