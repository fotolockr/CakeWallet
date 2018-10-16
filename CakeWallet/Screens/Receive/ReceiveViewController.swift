import Foundation
import FlexLayout
import PinLayout
import QRCode
import CakeWalletLib
import CakeWalletCore
import CWMonero

final class ReceiveViewController: BaseViewController<ReceiveView> {
    var paymentId: String? {
        get {
            return contentView.paymentIdTextField.text
        }
        
        set {
            contentView.paymentIdTextField.text = newValue
        }
    }
   
    var amount: Amount? {
        get {
            if let rawString = contentView.amountTextField.text {
                return MoneroAmount(from: rawString)
            }
            
            return nil
        }
        
        set {
            contentView.amountTextField.text = newValue?.formatted()
        }
    }
    
    var integratedAddress: String? {
        get {
            return contentView.integratedAddressTextField.text
        }
        
        set {
            contentView.integratedAddressTextField.text = newValue
        }
    }
    
    weak var receiveFlow: ReceiveFlow?
    let store: Store<ApplicationState>
    private(set) var address: String
    private var isSubaddress: Bool
    
    init(store: Store<ApplicationState>, receiveFlow: ReceiveFlow?) {
        self.store = store
        self.receiveFlow = receiveFlow
        self.address = store.state.walletState.address
        isSubaddress = false
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("receive", comment: "")
        contentView.switchOptionsButton.addTarget(self, action: #selector(switchOptionsButton), for: .touchUpInside)
        contentView.copyAddressButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        contentView.resetButton.addTarget(self, action: #selector(resetOptions), for: .touchUpInside)
        contentView.amountTextField.addTarget(self, action: #selector(onAmountChange), for: .editingChanged)
        contentView.newPaymentId.addTarget(self, action: #selector(generatePaymentId), for: .touchUpInside)
        contentView.copyIntegratedButton.alertPresenter = self
        contentView.copyPaymentIdButton.alertPresenter = self
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
            ),
            UIBarButtonItem(
                barButtonSystemItem: .bookmarks,
                target: self,
                action: #selector(presentSubaddresses)
            )
        ]
        changeAddress(store.state.walletState.address)
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
    func resetOptions() {
        amount = nil
        paymentId = nil
        contentView.integratedAddressTextField.text = nil
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
        showInfo(title: NSLocalizedString("copied", comment: ""), withDuration: 1, actions: [])
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
    
    @objc
    private func presentSubaddresses() {
        let subaddressesViewController = SubaddressesViewController(store: store)
        subaddressesViewController.onSelectedHandler = { [weak self] subaddress in
            self?.setSubaddress(subaddress)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(subaddressesViewController, animated: true)
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
        
        if paymentId != nil || amount != nil {
            result += "?"
        }
        
        if let paymentId = paymentId {
            result += "tx_payment_id=\(paymentId)"
        }
        
        if let amount = amount {
            if paymentId != nil {
                result += "&"
            }
            
            result += "tx_amount=\(amount.formatted())"
        }
        
        return result
    }
}
