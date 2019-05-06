import Foundation
import FlexLayout
import PinLayout
import QRCode
import CakeWalletLib
import CakeWalletCore
import CWMonero


final class ReceiveViewController: BaseViewController<ReceiveView>, StoreSubscriber {
    var paymentId: String? {
        get {
            return contentView.paymentIdTextField.textField.text
        }
        
        set {
            contentView.paymentIdTextField.textField.text = newValue
        }
    }
   
    var amount: Amount? {
        get {
            if let rawString = contentView.amountTextField.textField.text {
                return MoneroAmount(from: rawString)
            }
            
            return nil
        }
        
        set {
            contentView.amountTextField.textField.text = newValue?.formatted()
        }
    }
    
    var integratedAddress: String? {
        get {
            return contentView.integratedAddressTextField.textField.text
        }
        
        set {
            contentView.integratedAddressTextField.textField.text = newValue
        }
    }
    
    weak var dashboardFlow: DashboardFlow?
    let store: Store<ApplicationState>
    private(set) var address: String
    private var isSubaddress: Bool
    
    init(store: Store<ApplicationState>, dashboardFlow: DashboardFlow?) {
        self.store = store
        self.dashboardFlow = dashboardFlow
        self.address = store.state.walletState.address
        isSubaddress = false
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = NSLocalizedString("receive", comment: "")
        contentView.switchOptionsButton.addTarget(self, action: #selector(switchOptionsButton), for: .touchUpInside)
        contentView.copyAddressButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        contentView.paymentIdCopyButton.addTarget(self, action: #selector(onCopyPaymenIdAction), for: .touchUpInside)
        contentView.integratedAddressCopyButton.addTarget(self, action: #selector(onCopyIntegratedAddressAction), for: .touchUpInside)
        contentView.resetButton.addTarget(self, action: #selector(resetOptions), for: .touchUpInside)
        contentView.amountTextField.textField.addTarget(self, action: #selector(onAmountChange), for: .editingChanged)
        contentView.newPaymentId.addTarget(self, action: #selector(generatePaymentId), for: .touchUpInside)
        switchOptionsButton()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [\ApplicationState.walletState])
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
        
        if let subaddress = state.walletState.subaddress {
            setSubaddress(subaddress)
        }
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
        resetOptions()
        contentView.optionsView.isHidden = true
        hideOptions()
    }
    
    func changeAddress(_ address: String) {
        self.address = address
        contentView.addressLabel.text = address
        changeQR(address: address, paymentId: paymentId, amount: amount)
        contentView.addressLabel.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
    
    func showOptions() {
        contentView.switchOptionsButton.setTitle(NSLocalizedString("hide_options", comment: ""), for: .normal)
        contentView.integratedAddressContainer.isHidden = isSubaddress
        
        if isSubaddress {
            contentView.integratedAddressContainer.flex.height(0)
        }
        
        contentView.resetButton.isHidden = false
        contentView.optionsView.flex.height(nil)
        contentView.newPaymentId.isHidden = false
        contentView.optionsView.flex.markDirty()
        contentView.setNeedsLayout()
    }
    
    func hideOptions() {
        contentView.switchOptionsButton.setTitle(NSLocalizedString("more_options", comment: ""), for: .normal)
        contentView.optionsView.flex.height(0)
        contentView.resetButton.isHidden = true
        contentView.newPaymentId.isHidden = true
        contentView.optionsView.flex.markDirty()
        contentView.setNeedsLayout()
    }
    
    @objc
    func onCopyPaymenIdAction() {
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
        UIPasteboard.general.string = contentView.paymentIdTextField.textField.text
    }
    
    @objc
    func onCopyIntegratedAddressAction() {
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
        UIPasteboard.general.string = contentView.integratedAddressTextField.textField.text
    }
    
    @objc
    func resetOptions() {
        amount = nil
        paymentId = nil
        contentView.integratedAddressTextField.textField.text = nil
        changeQR(address: address, paymentId: paymentId, amount: amount)
    }
    
    @objc
    private func switchOptionsButton() {
        contentView.optionsView.isHidden = !contentView.optionsView.isHidden
        
        if contentView.optionsView.isHidden {
            hideOptions()
            return
        }
        
        showOptions()
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
        changeQR(address: address, paymentId: paymentId, amount: amount)
    }
    
    @objc
    private func generatePaymentId() {
        // FIX-ME: We don't need know anout MoneroWalletAdapter, but it's should not be part of WalletProtocol.
        guard
            let paymentId = MoneroWalletAdapter.generatePaymentId(),
            let wallet = currentWallet as? MoneroWallet else {
            return
        }
        
        let integratedAddress = wallet.integratedAddress(for: paymentId)
        self.paymentId = paymentId
        self.integratedAddress = integratedAddress
        changeQR(address: address, paymentId: paymentId, amount: amount)
    }
    
    private func changeQR(address: String, paymentId: String?, amount: Amount?) {
        let uri = MoneroUri(address: address, paymentId: paymentId, amount: amount)
        let qrCode = QRCode(uri.formatted())
        contentView.addressLabel.text = address
        contentView.qrImage.image = qrCode?.image
    }
}

//fixme

struct MoneroUri {
    let address: String
    let paymentId: String?
    let amount: Amount?
    
    init(address: String, paymentId: String? = nil, amount: Amount? = nil) {
        self.address = address
        self.paymentId = paymentId
        self.amount = amount
    }
    
    func formatted() -> String {
        var result = "monero:\(address)"
        var paymentIDString = ""
        var amountString = ""
        
        if
            let paymentId = paymentId,
            !paymentId.isEmpty {
            paymentIDString = "tx_payment_id=\(paymentId)"
        }
        
        if let amount = amount {
            let formattedAmount = amount.formatted()
            
            if !formattedAmount.isEmpty && Double(formattedAmount) != 0 {
                amountString += "tx_amount=\(amount.formatted())"
            }
        }
        
        if !paymentIDString.isEmpty || !amountString.isEmpty {
            result += "?"
        }
        
        if !paymentIDString.isEmpty {
            result += paymentIDString
        }
        
        if !amountString.isEmpty {
            if !paymentIDString.isEmpty {
                result += "&"
            }
            
            result += amountString
        }
        
        
        return result
    }
}
