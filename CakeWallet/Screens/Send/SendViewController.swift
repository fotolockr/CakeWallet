import UIKit
import CakeWalletLib
import CakeWalletCore
import CWMonero

protocol QRUri {
    var uri: String { get }
    var address: String { get }
}

struct MoneroQRResult: QRUri {
    let uri: String
    
    var address: String {
        return self.uri.slice(from: "monero:", to: "?") ?? self.uri
    }
    var amount: Amount? {
        guard let amountStr = self.uri.slice(from: "tx_amount=", to: "&") else {
            return nil
        }
        
        return MoneroAmount(from: amountStr)
    }
    var paymentId: String? {
        return self.uri.slice(from: "tx_payment_id=", to: "&")
    }
    
    init(uri: String) {
        self.uri = uri
    }
}

struct BitcoinQRResult: QRUri {
    let uri: String
    
    var address: String {
        return self.uri.replacingOccurrences(of: "bitcoin:", with: "")
    }
    
    init(uri: String) {
        self.uri = uri
    }
}

struct DefaultCryptoQRResult: QRUri {
    let uri: String
    
    var address: String {
        return self.uri.replacingOccurrences(of: "\(targetDescription):", with: "")
    }
    
    private let target: CryptoCurrency
    private var targetDescription: String {
        switch target {
        case .bitcoin:
            return "bitcoin"
        case .bitcoinCash:
            return "bitcoincash"
        case .dash:
            return "dash"
        case .ethereum:
            return "ethereum"
        case .liteCoin:
            return "litecoin"
        case .monero:
            return "monero"
        }
    }
    
    init(uri: String, for target: CryptoCurrency) {
        self.uri = uri
        self.target = target
    }
}


final class SendViewController: BaseViewController<SendView>, StoreSubscriber, QRUriUpdateResponsible {
    private static let allSymbol = NSLocalizedString("all", comment: "")
    
    let store: Store<ApplicationState>
    let address: String?
    var priority: TransactionPriority {
        return store.state.settingsState.transactionPriority
    }
    private weak var alert: UIAlertController?
    private var price: Double {
        return store.state.balanceState.price
    }
    
    init(store: Store<ApplicationState>, address: String?) {
        self.store = store
        self.address = address
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("send", comment: "")
        contentView.takeFromAddressBookButton.addTarget(self, action: #selector(takeFromAddressBook), for: .touchUpInside)
        contentView.sendAllButton.addTarget(self, action: #selector(setAllAmount), for: .touchUpInside)
        contentView.cryptoAmountTextField.textField.addTarget(self, action: #selector(onCryptoValueChange(_:)), for: .editingChanged)
        contentView.fiatAmountTextField.textField.addTarget(self, action: #selector(onFiatValueChange(_:)), for: .editingChanged)
        contentView.estimatedFeeTitleLabel.text = NSLocalizedString("estimated_fee", comment: "") + ":"
        contentView.addressView.presenter = self
        contentView.addressView.updateResponsible = self
        updateEstimatedFee(for: store.state.settingsState.transactionPriority)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let doneButton = StandartButton(image: UIImage(named: "close_symbol")?.resized(to: CGSize(width: 12, height: 12)))
        doneButton.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        doneButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        contentView.sendButton.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneButton)
        store.subscribe(self, onlyOnChange: [
            \ApplicationState.balanceState,
            \ApplicationState.transactionsState,
            ])
        store.dispatch(
            TransactionsActions.calculateEstimatedFee(
                withPriority: priority
            )
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let address = self.address {
            contentView.addressView.textView.text = address
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.dispatch(TransactionsState.Action.changedSendingStage(.none))
        store.unsubscribe(self)
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        updateWallet(name: state.walletState.name)
        updateWallet(type: state.walletState.walletType)
        updateWallet(balance: state.balanceState.unlockedBalance)
        updateSendingStage(state.transactionsState.sendingStage)
        updateFiat(state.settingsState.fiatCurrency)
        updateEstimatedFee(state.transactionsState.estimatedFee)
    }
    
    // MARK: QRUriUpdateResponsible
    
    func update(uri: QRUri) {
        guard let uri = uri as? MoneroQRResult else {
            return
        }
        
        updateAddress(uri.address)
        
        if let amount = uri.amount {
            updateAmount(amount)
        }
        
        updatePaymentId(uri.paymentId)
    }
    
    func getCrypto(for addressView: AddressView) -> CryptoCurrency {
        return .monero
    }
    
    @objc
    private func takeFromAddressBook() {
        let addressBookVC = AddressBookViewController(addressBook: AddressBook.shared, store: self.store, isReadOnly: true)
        addressBookVC.doneHandler = { [weak self] address in
            self?.contentView.addressView.textView.text = address
        }
        let sendNavigation = UINavigationController(rootViewController: addressBookVC)
        self.present(sendNavigation, animated: true)
    }
    
    @objc
    private func dismissAction() {
        dismiss(animated: true) { [weak self] in
            self?.onDismissHandler?()
        }
    }
    
    private func updateWallet(name: String) {
        guard name != contentView.cryptoAmountTitleLabel.text else {
            return
        }
        contentView.walletNameLabel.text = name
        contentView.walletNameLabel.flex.markDirty()
        contentView.walletContainer.flex.layout()
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func updateWallet(balance: Amount) {
        let balance = balance.formatted()
        guard balance != contentView.cryptoAmountTitleLabel.text else {
            return
        }
        contentView.cryptoAmountValueLabel.text = balance
        contentView.cryptoAmountValueLabel.flex.markDirty()
        contentView.walletContainer.flex.layout()
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func updateWallet(type: WalletType) {
        let title = type.string()
            + " "
            + NSLocalizedString("available_balance", comment: "")
        guard title != contentView.cryptoAmountTitleLabel.text else {
            return
        }
        contentView.cryptoAmountTitleLabel.text = type.currency.formatted()
            + " "
            + NSLocalizedString("available_balance", comment: "")
//        contentView.cryptoAmountTextField.placeholder = type.currency.formatted()
//        contentView.cryptoAmountTextField.title = type.currency.formatted()
        contentView.cryptoAmountTitleLabel.flex.markDirty()
        contentView.walletContainer.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func updateFiat(_ fiat: FiatCurrency) {
//        contentView.fiatAmountTextField.placeholder = fiat.formatted()
//        contentView.fiatAmountTextField.title = fiat.formatted()
    }
    
    @objc
    private func onCryptoValueChange(_ textField: UITextField) {
        guard
            let fiatValueStr = textField.text?.replacingOccurrences(of: ",", with: "."),
            let fiatValue = Double(fiatValueStr) else {
                contentView.fiatAmountTextField.textField.text = nil
                return
        }
        
        let val = fiatValue * price
        contentView.fiatAmountTextField.textField.text  = String(val)
    }
    
    @objc
    private func onFiatValueChange(_ textField: UITextField) {
        guard
            let cryptoValueStr = textField.text?.replacingOccurrences(of: ",", with: "."),
            let cryptoValue = Double(cryptoValueStr) else {
                contentView.cryptoAmountTextField.textField.text  = nil
                return
        }
        
        let val = cryptoValue / price
        contentView.cryptoAmountTextField.textField.text  = String(format: "%.12f", val)
    }
    
    private func updateSendingStage(_ stage: SendingStage) {
        switch stage {
        case let .pendingTransaction(tx):
            guard let alert = alert else {
                self.onTransactionCreated(tx)
                return
            }
            
            alert.dismiss(animated: true) {
                self.onTransactionCreated(tx)
            }
        case .commited:
            guard let alert = alert else {
                self.onTransactionCommited()
                return
            }
            
            alert.dismiss(animated: true) {
                self.onTransactionCommited()
            }
        default:
            break
        }
    }
    
    private func updateEstimatedFee(_ fee: Amount) {
        let fiatCurrency = store.state.settingsState.fiatCurrency
        let price = store.state.balanceState.price
        let fiatBalance = calculateFiatAmount(fiatCurrency, price: price, balance: fee)
        let formattedFee = MoneroAmountParser.formatValue(fee.value) ?? "0.0"
        let formattedFiat = fiatBalance.formatted()
        contentView.estimatedFeeValueLabel.text = String(format: "%@ (%@)", formattedFee, formattedFiat)
        let estimatedFeeContrinerWidth = contentView.estimatedFeeContriner.frame.size.width
        let totalWidth = estimatedFeeContrinerWidth
        let titleWidth = contentView.estimatedFeeTitleLabel.frame.size.width
        let width = totalWidth - titleWidth

        if width > 0 {
            contentView.estimatedFeeValueLabel.flex.width(width).markDirty()
        } else {
            contentView.estimatedFeeValueLabel.flex.markDirty()
        }
        
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func onTransactionCreating() {
        let sendAction = CWAlertAction(title: NSLocalizedString("send", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.createTransaction()
            }
        }
        
        showInfo(
            title: NSLocalizedString("creating_transaction", comment: ""),
            message: NSLocalizedString("confirm_sending", comment: ""),
            actions: [sendAction, CWAlertAction.cancelAction]) { alert in
        }
    }
    
    private func onTransactionCreated(_ pendingTransaction: PendingTransaction) {
        let description = pendingTransaction.description
        let message = NSLocalizedString("commit_transaction", comment: "")
            + "\n"
            + NSLocalizedString("amount", comment: "")
            + ": "
            + description.amount.formatted()
            + "\n"
            + NSLocalizedString("fee", comment: "")
            + ": "
            + MoneroAmountParser.formatValue(description.fee.value)
        let commitAction = CWAlertAction(title: NSLocalizedString("Ok", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.commit(pendingTransaction: pendingTransaction)
            }
        }
        let cacelAction = CWAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.store.dispatch(
                    TransactionsState.Action.changedSendingStage(.none)
                )
            }
        }
        
        showInfo(title: NSLocalizedString("confirm_sending", comment: ""), message: message, actions: [commitAction, cacelAction])
    }
    
    private func commit(pendingTransaction: PendingTransaction) {
        showSpinner(withTitle: NSLocalizedString("creating_transaction", comment: "")) { [weak self] alert in
            self?.store.dispatch(
                WalletActions.commit(
                    transaction: pendingTransaction,
                    handler: { result in
                        alert.dismiss(animated: true) {
                            switch result {
                            case .success(_):
                                self?.onTransactionCommited()
                            case let .failed(error):
                                self?.showError(error: error)
                            }
                        }
                })
            )
        }
    }
    
    private func onTransactionCommited() {
        let okAction = CWAlertAction(title: NSLocalizedString("Ok", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.resetForm()
            }
        }
        
        showInfo(title: NSLocalizedString("transaction_created", comment: ""), actions: [okAction])
    }
    
    private func createTransaction(_ handler: (() -> Void)? = nil) {
        let authController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        let navController = UINavigationController(rootViewController: authController)
        let paymentID = contentView.paymentIdTextField.textField.text  ?? ""
        
        authController.handler = { [weak self] in
            authController.dismiss(animated: true) {
                self?.showSpinner(withTitle: NSLocalizedString("creating_transaction", comment: ""), callback: { alert in
                    let amount = self?.contentView.cryptoAmountTextField.textField.text  == SendViewController.allSymbol
                        ? nil
                        : MoneroAmount(from: self!.contentView.cryptoAmountTextField.textField.text?.replacingOccurrences(of: ",", with: ".") ?? "0.0")
                    let address = self?.contentView.addressView.textView.text ?? ""
                    guard let priority = self?.priority else { return }
                    self?.store.dispatch(
                        WalletActions.send(
                            amount: amount,
                            toAddres: address,
                            paymentID: paymentID,
                            priority: priority,
                            handler: { result in
                                alert.dismiss(animated: true) {
                                    switch result {
                                    case let .success(pendingTransaction):
                                        self?.onTransactionCreated(pendingTransaction)
                                    case let .failed(error):
                                        self?.showError(error: error)
                                    }
                                }
                        }
                        )
                    )
                })
            }
        }
        
        present(navController, animated: true)
    }
    
    private func resetForm() {
        contentView.fiatAmountTextField.textField.text  = ""
        contentView.cryptoAmountTextField.textField.text  = ""
        contentView.addressView.textView.text = ""
        store.dispatch(TransactionsState.Action.changedSendingStage(.none))
    }
    
    @objc
    private func sendAction() {
        onTransactionCreating()
    }
    
    @objc
    private func setAllAmount() {
        contentView.cryptoAmountTextField.textField.text  = SendViewController.allSymbol
    }
    
    private func updateAmount(_ amount: Amount) {
        contentView.cryptoAmountTextField.textField.text  = amount.formatted()
    }
    
    private func updatePaymentId(_ paymentId: String?) {
        contentView.paymentIdTextField.textField.text  = paymentId
    }
    
    private func updateAddress(_ address: String) {
        contentView.addressView.textView.text = address
    }
    
    private func updateEstimatedFee(for priority: TransactionPriority) {
        contentView.estimatedDescriptionLabel.text = NSLocalizedString("Currently the fee is set at", comment: "")
            + " "
            + priority.formatted()
            + " "
            + NSLocalizedString("priority", comment: "")
            + ". "
            + NSLocalizedString("Transaction priority can be adjusted in the settings", comment: "")
    }
}
