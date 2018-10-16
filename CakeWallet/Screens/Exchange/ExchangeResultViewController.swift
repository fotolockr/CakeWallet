import UIKit
import CakeWalletCore
import CakeWalletLib
import QRCode

final class ExchangeResultViewController: BaseViewController<ExchangeResultView>, StoreSubscriber {
    let store: Store<ApplicationState>
    let amount: Amount
    private var trade: ExchangeTrade?
    private var sent: Bool
    private lazy var updateTradeStateTimer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
            self?.store.dispatch(ExchangeActionCreators.shared.updateCurrentTradeState()) {
                if self?.store.state.exchangeState.trade?.status == .complete {
                    self?.updateTradeStateTimer.invalidate()
                }
            }
        }
    }()
    
    init(store: Store<ApplicationState>, amount: Amount) {
        self.store = store
        self.amount = amount
        self.sent = false
        super.init()
    }
    
    override func configureBinds() {
        title = NSLocalizedString("exchange", comment: "")
        updateTradeStateTimer.fire()
        contentView.copyAddressButton.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
        contentView.copyIdButton.addTarget(self, action: #selector(copyId), for: .touchUpInside)
        contentView.confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        
        contentView.copyIdButton.textHandler = { [weak self] in
            return self?.contentView.idLabel.text ?? ""
        }
        contentView.copyIdButton.alertPresenter = self
        contentView.copyAddressButton.textHandler = { [weak self] in
            return self?.contentView.idLabel.text ?? ""
        }
        contentView.copyAddressButton.alertPresenter = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [\ApplicationState.exchangeState])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        if
            let trade = store.state.exchangeState.trade,
            trade != self.trade {
            self.trade = trade
            updateInfoAbout(trade: trade)
        }
    }
    
    func updateID(with id: String) {
        contentView.idLabel.text = "ID: \(id)"
    }
    
    func updateAmount(with amunt: Amount) {
        contentView.amountLabel.text = NSLocalizedString("amount", comment: "")
            + ": "
            + amunt.formatted()
            + " "
            + amunt.currency.formatted()
    }

    
//    func updateMinAmount(with minAmunt: Amount) {
//        contentView.minAmountLabel.text = NSLocalizedString("min", comment: "")
//        + ": "
//        + minAmunt.formatted()
//        + " "
//        + minAmunt.currency.formatted()
//    }
//
//    func updateMaxAmount(with maxAmount: Amount) {
//        contentView.maxAmountLabel.text = NSLocalizedString("max", comment: "")
//            + ": "
//            + maxAmount.formatted()
//            + " "
//            + maxAmount.currency.formatted()
//    }
    
    func updateAddress(with address: String) {
        contentView.addressLabel.text = address
        contentView.addressLabel.flex.markDirty()
        contentView.qrImageView.image = QRCode(address)?.image
    }
    
    func updateTrade(state: ExchangeTradeState) {
        let stateString = state.formatted()
        contentView.statusLabel.text = NSLocalizedString("state", comment: "")
            + ": "
            + stateString
        contentView.statusLabel.flex.markDirty()
    }
    
    func updateInfoAbout(trade: ExchangeTrade) {
        var description = ""
        
        updateID(with: trade.id)
        updateAmount(with: self.amount)
//        updateMinAmount(with: trade.min)
//        updateMaxAmount(with: trade.max)
        updateAddress(with: trade.inputAddress)
        updateTrade(state: trade.status)
        let amount = "\(self.amount.formatted()) \(self.amount.currency.formatted())"
        let resultDescription: String
        
        if trade.inputCurrency == store.state.walletState.walletType.currency {
            let name = store.state.walletState.name
            resultDescription = String(format: NSLocalizedString("exchange_result_confirm_text", comment: ""), amount, name)
                + "\n\n"
                + NSLocalizedString("exchange_result_confirm_sending", comment: "")
        } else {
            resultDescription = String(format: NSLocalizedString("exchange_result_description_text", comment: ""), amount)
        }
        
        if !sent {
            contentView.confirmButton.isHidden = trade.inputCurrency != store.state.walletState.walletType.currency
            contentView.confirmButton.flex.markDirty()
        }
        
        description += " \n\n\n\n"
        description += "*" + NSLocalizedString("exchange_result_write_down_trade_id", comment: "")
        contentView.resultDescriptionLabel.text = resultDescription
        contentView.resultDescriptionLabel.flex.markDirty()
        contentView.descriptionTextView.text = description
        contentView.descriptionTextView.flex.markDirty()
        contentView.cardView.flex.markDirty()
        contentView.rootFlexContainer.flex.layout(mode: .adjustHeight)
        contentView.layoutSubviews()
    }
    
    @objc
    private func copyAddress() {
        guard let address = store.state.exchangeState.trade?.inputAddress else {
            return
        }
        
        UIPasteboard.general.string = address
    }
    
    @objc
    private func copyId() {
        guard let id = store.state.exchangeState.trade?.id else {
            return
        }
        
        UIPasteboard.general.string = id
    }
    
    @objc
    private func confirm() {
        guard store.state.exchangeState.trade?.inputCurrency == store.state.walletState.walletType.currency else {
            return
        }
        
        createTransaction()
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
            actions: [sendAction, CWAlertAction.cancelAction]
        )
    }
    
    private func onTransactionCreated(_ pendingTransaction: PendingTransaction) {
        let description = pendingTransaction.description
        let message = NSLocalizedString("commit_transaction", comment:  "")
            + "\n" + NSLocalizedString("amount", comment: "")
            + ": " + description.amount.formatted()
            + "\n" + NSLocalizedString("fee", comment: "")
            + ": " + description.fee.formatted()
        
        let commitAction = CWAlertAction(title: NSLocalizedString("Ok", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.commit(pendingTransaction: pendingTransaction)
            }
        }
        
        let cancelAction = CWAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.store.dispatch(
                    TransactionsState.Action.changedSendingStage(.none)
                )
            }
        }
        
        showInfo(title: NSLocalizedString("confirm_sending", comment: ""), message: message, actions: [commitAction, cancelAction])
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
                                break
                            }
                        }
                })
            )
        }
    }
    
    private func onTransactionCommited() {
        let okAction = CWAlertAction(title: NSLocalizedString("Ok", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.contentView.confirmButton.isHidden = true
                self?.sent = true
            }
        }
        
        showInfo(title: NSLocalizedString("transaction_created", comment: ""), actions: [okAction])
    }
    
    private func createTransaction(_ handler: (() -> Void)? = nil) {
        let authController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        let navController = UINavigationController(rootViewController: authController)
        authController.handler = { [weak self] in
            authController.dismiss(animated: true) {
                self?.showSpinner(withTitle: NSLocalizedString("creating_transaction", comment: ""), callback: { alert in
                    guard
                        let priority = self?.store.state.settingsState.transactionPriority,
                        let address = self?.store.state.exchangeState.trade?.inputAddress,
                        let amount = self?.amount else { return }
                    
                    self?.store.dispatch(
                        WalletActions.send(
                            amount: amount,
                            toAddres: address,
                            paymentID: "",
                            priority: priority,
                            handler: { result in
                                alert.dismiss(animated: true) {
                                    switch result {
                                    case let .success(pendingTransaction):
                                        self?.onTransactionCreated(pendingTransaction)
                                    case let .failed(error):
                                        self?.showError(error: error)
                                        break
                                    }
                                }
                        })
                    )
                })
            }
        }
        
        present(navController, animated: true)
    }
}
