import UIKit
import CakeWalletCore
import CWMonero
import CakeWalletLib
import RxCocoa
import RxSwift

final class SubaddressCell: FlexCell {
    func setup(label: String, address: String) {
        textLabel?.text = label
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        
        contentView.flex.define { flex in
            
        }
    }
}

extension Subaddress: CellItem {
    func setup(cell: SubaddressCell) {
        cell.setup(label: label, address: address)
    }
}

final class SubaddressesViewController: BaseViewController<SubaddressesView>, UITableViewDataSource, UITableViewDelegate, StoreSubscriber {
    weak var flow: DashboardFlow?
    private  let store: Store<ApplicationState>
    private  var subaddresses: [Subaddress] {
        didSet {
            contentView.table.reloadData()
        }
    }
    private let disposeBag: DisposeBag
    
    init(store: Store<ApplicationState>) {
        self.store = store
        subaddresses = []
        disposeBag = DisposeBag()
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("subaddresses", comment: "")
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        contentView.table.dataSource = self
        contentView.table.delegate = self
        contentView.table.separatorStyle = .none
        contentView.table.register(items: [Subaddress.self])
        contentView.newSubaddressButton.addTarget(self, action: #selector(addSubaddressAction), for: .touchUpInside)
        let resetButton = UIBarButtonItem()
        resetButton.title = "Unselect"
        resetButton.target = self
        resetButton.action = #selector(reset)
        
        resetButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .normal)
        resetButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .highlighted)
        resetButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.gray], for: .disabled)
        
        navigationItem.rightBarButtonItem = resetButton
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
        navigationItem.rightBarButtonItem?.isEnabled = state.walletState.subaddress != nil
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subaddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = subaddresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        addEditButton(for: cell, subaddress: item)
        return cell
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
        store.dispatch(WalletState.Action.changedSubaddress(sub))
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func reset() {
        store.dispatch(WalletState.Action.changedSubaddress(nil))
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func addSubaddressAction() {
        guard let label = contentView.newSubaddressTextiField.textField.text else {
            return
        }
                
        store.dispatch(
            SubaddressesActions.addNew(
                withLabel: label,
                handler: { [weak self] in
                    DispatchQueue.main.async {
                        self?.contentView.newSubaddressTextiField.textField.text = nil
                    }
            })
        )
    }
    
    private func editSubaddress(_ subaddress: Subaddress) {
        flow?.change(route: .editSubaddress(subaddress))
    }
    
    private func addEditButton(for cell: UITableViewCell, subaddress: Subaddress) {
        let editButton = UIButton()
        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        editButton.setTitleColor(.blueBolt, for: .normal)
        editButton.titleLabel?.font = applyFont(ofSize: 12)
        editButton.titleLabel?.textAlignment = .right
        editButton.sizeToFit()
        editButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.editSubaddress(subaddress)
        }).disposed(by: disposeBag)
        cell.accessoryView = editButton
    }
}
