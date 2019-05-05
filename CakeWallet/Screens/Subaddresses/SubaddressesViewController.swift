import UIKit
import CakeWalletCore
import CWMonero
import CakeWalletLib
import RxCocoa
import RxSwift
import FlexLayout


//final class SubaddressCell: FlexCell {
//    func setup(label: String, address: String) {
//        textLabel?.text = label
//    }
//
//    override func configureConstraints() {
//        super.configureConstraints()
//
//        contentView.flex.define { flex in
//
//        }
//    }
//}


final class SubaddressCell: FlexCell {
    static let height = 56 as CGFloat
    let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .white
        backgroundColor = .clear
        selectionStyle = .none
        
        nameLabel.font = applyFont(ofSize: 16)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        
        contentView.flex
            .direction(.row).justifyContent(.spaceBetween).alignItems(.center)
            .height(SubaddressCell.height).width(100%)
            .marginTop(15).paddingVertical(5)
            .define { flex in
                flex.addItem(nameLabel)
        }
    }
    
    func configure(name: String) {
        nameLabel.text = name
        nameLabel.flex.markDirty()
        
        contentView.flex.layout()
    }
}


extension Subaddress: CellItem {
    func setup(cell: SubaddressCell) {
        cell.configure(name: label)
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
        
        contentView.table.dataSource = self
        contentView.table.delegate = self
        contentView.table.separatorStyle = .none
        contentView.table.register(items: [Subaddress.self])
        contentView.newSubaddressButton.addTarget(self, action: #selector(addSubaddressAction), for: .touchUpInside)
<<<<<<< HEAD
<<<<<<< HEAD
        
        let resetButton = UIBarButtonItem()
        resetButton.title = "Reset"
        resetButton.action = #selector(reset)
        
        resetButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .normal)
        resetButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .highlighted)
        
        navigationItem.rightBarButtonItem = resetButton
=======
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unselect", style: .plain, target: self, action: #selector(reset))
>>>>>>> Fixes
=======
        
        let resetButton = makeTitledNavigationButton(title: NSLocalizedString("reset", comment: ""), target: self, action: #selector(reset))
        navigationItem.rightBarButtonItems = [resetButton]
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
>>>>>>> Subaddresses redesign
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
    
    func onStateChange(_ state: ApplicationState) {
        subaddresses = state.subaddressesState.subaddresses
        navigationItem.rightBarButtonItem?.isEnabled = state.walletState.subaddress != nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subaddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = subaddresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)

        return cell
    }
    
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
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler ) in
            guard let subaddress = self?.subaddresses[indexPath.row] else {
                return
            }
         
            self?.editSubaddress(subaddress)
        }
        
        editAction.image = UIImage(named: "edit_icon")
        
        let confrigation = UISwipeActionsConfiguration(actions: [editAction])
        return confrigation
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
    
//    private func addEditButton(for cell: UITableViewCell, subaddress: Subaddress) {
//        let editButton = UIButton()
//        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
//        editButton.setTitleColor(.blueBolt, for: .normal)
//        editButton.titleLabel?.font = applyFont(ofSize: 12)
//        editButton.titleLabel?.textAlignment = .right
//        editButton.sizeToFit()
//        editButton.rx.tap.subscribe(onNext: { [weak self] _ in
//            self?.editSubaddress(subaddress)
//        }).disposed(by: disposeBag)
//        cell.accessoryView = editButton
//    }
}
