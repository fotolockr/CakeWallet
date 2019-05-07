import UIKit
import CakeWalletCore
import CWMonero
import CakeWalletLib
import RxCocoa
import RxSwift
import FlexLayout
import SwipeCellKit


final class SubaddressCell: FlexCell {
    static let height = 56 as CGFloat
    let nameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func configureView() {
        super.configureView()
        contentView.backgroundColor = .white
        backgroundColor = .clear
        selectionStyle = .none
        
        nameLabel.font = applyFont(ofSize: 16)
    }
    
    override func configureConstraints() {
        super.configureConstraints()
        
        contentView.flex
            .direction(.row)
            .alignItems(.center)
            .height(SubaddressCell.height)
            .width(100%)
            .padding(5, 25, 5, 15)
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

final class SubaddressesViewController: BaseViewController<SubaddressesView>, UITableViewDataSource, UITableViewDelegate, StoreSubscriber, SwipeTableViewCellDelegate {
    weak var flow: DashboardFlow?
    private  let store: Store<ApplicationState>
    private  var subaddresses: [Subaddress] {
        didSet {
            contentView.table.reloadData()
        }
    }
    private let disposeBag: DisposeBag
    private var unselectButton: UIBarButtonItem?
    
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

        let resetButton = makeTitledNavigationButton(title: NSLocalizedString("reset", comment: ""), target: self, action: #selector(reset))
        let addButton = makeIconedNavigationButton(iconName: "add_icon_purple", target: self, action: #selector(addSubaddress))
        navigationItem.rightBarButtonItems = [addButton, resetButton]
        unselectButton = resetButton
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
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
    
    @objc
    private func addSubaddress() {
        flow?.change(route: .addOrEditSubaddress(nil))
    }
    
    func onStateChange(_ state: ApplicationState) {
        subaddresses = state.subaddressesState.subaddresses
        unselectButton?.isEnabled = state.walletState.subaddress != nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subaddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = subaddresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.addSeparator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { [weak self] action, indexPath in
            guard let subaddress = self?.subaddresses[indexPath.row] else {
                return
            }

            self?.editSubaddress(subaddress)
        }
        
        
        editAction.image = UIImage(named: "edit_icon")?.resized(to: CGSize(width: 20, height: 20))

        return [editAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SubaddressCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard subaddresses.count > indexPath.row else {
            return
        }
        
        let sub = subaddresses[indexPath.row]
        
        
        print("SUB", sub)
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
    
    private func editSubaddress(_ subaddress: Subaddress) {
        flow?.change(route: .addOrEditSubaddress(subaddress))
    }
}
