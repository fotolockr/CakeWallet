import Foundation
import FlexLayout
import PinLayout
import QRCode
import CakeWalletLib
import CakeWalletCore
import CWMonero
import SwipeCellKit

final class ReceiveViewController: BaseViewController<ReceiveView>, StoreSubscriber, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    var amount: Amount? {
        get {
            if let rawString = contentView.amountTextField.text {
                return MoneroAmount(from: rawString.replacingOccurrences(of: ",", with: "."))
            }
            
            return nil
        }
        
        set {
            contentView.amountTextField.text = newValue?.formatted()
        }
    }
    
    weak var dashboardFlow: DashboardFlow?
    let store: Store<ApplicationState>
    private(set) var address: String
    private var isSubaddress: Bool
    private var subaddresses: [Subaddress] {
        didSet {
            contentView.table.reloadData()
        }
    }
    
    private var currentSubaddress: UInt32 {
        return store.state.walletState.subaddress?.index ?? 0
    }
    
    init(store: Store<ApplicationState>, dashboardFlow: DashboardFlow?) {
        self.store = store
        self.dashboardFlow = dashboardFlow
        self.address = store.state.walletState.address
        isSubaddress = false
        subaddresses = []
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("receive", comment: "")
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.separatorStyle = .none
        contentView.table.register(items: [Subaddress.self])
        let onAddressTapGesture = UITapGestureRecognizer(target: self, action: #selector(copyAction))
        let onQrImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(copyAction))
        contentView.addressLabel.addGestureRecognizer(onAddressTapGesture)
        contentView.addressLabel.isUserInteractionEnabled = true
        contentView.qrImage.addGestureRecognizer(onQrImageTapGesture)
        contentView.qrImage.isUserInteractionEnabled = true
        contentView.addSubaddressButton.addTarget(self, action: #selector(addSubaddressAction), for: .touchUpInside)
        contentView.amountTextField.addTarget(self, action: #selector(onAmountChange), for: .editingChanged)
        let doneButton = StandartButton(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 10, height: 12)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(named: "share_icon")?.resized(to: CGSize(width: 20, height: 20)),
                style: .plain,
                target: self,
                action: #selector(shareAction)
            )
        ]
        changeAddress(store.state.walletState.address)
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [
            \ApplicationState.walletState,
            \ApplicationState.subaddressesState])
        store.dispatch(SubaddressesActions.update)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.unsubscribe(self)
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        if address != state.walletState.address {
            changeAddress(state.walletState.address)
        }
        
        subaddresses = state.subaddressesState.subaddresses
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subaddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = subaddresses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.isCurrent(currentSubaddress == item.index)
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
        store.dispatch(WalletState.Action.changedSubaddress(sub))
    }
    
    func setSubaddress(_ subaddress: Subaddress) {
        isSubaddress = subaddress.address != store.state.walletState.address
        
        if
            isSubaddress,
            let label = subaddress.label {
            title = String(format: "%@ %@", NSLocalizedString("receive", comment: ""), label)
        } else {
            title = NSLocalizedString("receive", comment: "")
        }
        
        changeAddress(subaddress.address)
    }
    
    func changeAddress(_ address: String) {
        self.address = address
        contentView.addressLabel.text = address
        changeQR(address: address, paymentId: nil, amount: amount)
        contentView.addressLabel.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    @objc
    private func shareAction() {
        let activityViewController = UIActivityViewController(
            activityItems: [address],
            applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.message, UIActivityType.mail,
            UIActivityType.print, UIActivityType.copyToPasteboard]
        present(activityViewController, animated: true)
    }
    
    @objc
    private func copyAction() {
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
        
        UIPasteboard.general.string = address
    }
    
    @objc
    private func onAmountChange(_ textField: UITextField) {
        changeQR(address: address, paymentId: nil, amount: amount)
    }
    
    private func changeQR(address: String, paymentId: String?, amount: Amount?) {
        let uri = MoneroUri(address: address, paymentId: paymentId, amount: amount)
        let qrCode = QRCode(uri.formatted())
        contentView.addressLabel.text = address
        contentView.qrImage.image = qrCode?.image
    }
    
    private func editSubaddress(_ subaddress: Subaddress) {
        dashboardFlow?.change(route: .addOrEditSubaddress(subaddress))
    }
    
    @objc
    private func addSubaddressAction() {
        dashboardFlow?.change(route: .addOrEditSubaddress(nil))
    }
}
