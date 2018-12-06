import UIKit
import CakeWalletCore
import CakeWalletLib
import QRCode
import CWMonero

extension TimeInterval: Formatted {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    public func formatted() -> String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}

extension UILabel {
    
    func boldRange(_ range: Range<String.Index>) {
        if let text = self.attributedText {
            let attr = NSMutableAttributedString(attributedString: text)
            let start = text.string.distance(from: text.string.startIndex, to: range.lowerBound)
            let length = text.string.distance(from: range.lowerBound, to: range.upperBound)
            attr.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: NSMakeRange(start, length))
            self.attributedText = attr
        }
    }
    
    func boldSubstring(_ substr: String) {
        if let text = self.attributedText {
            var range = text.string.range(of: substr)
            let attr = NSMutableAttributedString(attributedString: text)
            while range != nil {
                let start = text.string.distance(from: text.string.startIndex, to: range!.lowerBound)
                let length = text.string.distance(from: range!.lowerBound, to: range!.upperBound)
                var nsRange = NSMakeRange(start, length)
                let font = attr.attribute(NSAttributedStringKey.font, at: start, effectiveRange: &nsRange) as! UIFont
                if !font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    break
                }
                range = text.string.range(of: substr, options: NSString.CompareOptions.literal, range: range!.upperBound..<text.string.endIndex, locale: nil)
            }
            if let r = range {
                boldRange(r)
            }
        }
    }
}



final class ExchangeResultViewController: BaseViewController<ExchangeResultView>, StoreSubscriber {
    let store: Store<ApplicationState>
    let amount: Amount
    private var trade: ExchangeTrade?
    private var sent: Bool
    private var timeoutTimerRun: Bool = false
    private lazy var updateTradeStateTimer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
            //getOrderStatusForXMRTO
            
            guard let trade = self?.store.state.exchangeState.trade else {
                return
            }
            
            if case trade.provider = ExchangeProvider.xmrto {
                self?.store.dispatch(ExchangeActionCreators.shared.getOrderStatusForXMRTO(uuid: trade.id)) {
                    if
                        self?.store.state.exchangeState.trade?.status == .timeout
                        || self?.store.state.exchangeState.trade?.status == .btcSent {
                        self?.updateTradeStateTimer.invalidate()
                    }
                }
                return
            }
            
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
        contentView.idLabel.boldSubstring("ID:")
    }
    
    func updateAmount(with amunt: Amount) {
        contentView.amountLabel.text = NSLocalizedString("amount", comment: "")
            + ": "
            + amunt.formatted()
            + " "
            + amunt.currency.formatted()
        contentView.amountLabel.boldSubstring(NSLocalizedString("amount", comment: ""))
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
    }
    
    func updateQR(address: String, paymentID: String? = nil, amount: Amount? = nil) {
        var text = ""
        
        if
            let trade = self.trade,
            case .monero = trade.inputCurrency {
            let uri = MoneroUri(address: address, paymentId: paymentID, amount: amount)
            text = uri.formatted()
        } else {
            text = address
        }
        
        contentView.qrImageView.image = QRCode(text)?.image

    }
    
    func updateTrade(trade: ExchangeTrade) {
        let status = trade.status
        
        if
            case .btcSent = status,
            let outputTxID = trade.outputTxID {
            contentView.btcTxIDLabel.text = "BTC transaction ID:"
            contentView.btcTxIDLabel.boldSubstring("BTC transaction ID:")
            contentView.btcTxIDLabel.flex.markDirty()
            contentView.btcTxIDTextLabel.text = outputTxID
            contentView.btcTxIDTextLabel.flex.markDirty()
        }
        
        contentView.btcTxIDRow.flex.width(contentView.infoColumn.frame.size.width).layout()
        contentView.statusLabel.text = String(format: "%@: %@", NSLocalizedString("status", comment: ""), status.formatted())
        contentView.statusLabel.boldSubstring(NSLocalizedString("status", comment: ""))
        contentView.statusLabel.flex.markDirty()
    }
    
    func updateInfoAbout(trade: ExchangeTrade) {
        var description = ""
        let amount: Amount
        
        if let _amount = trade.value {
            amount = _amount
        } else {
            amount = self.amount
        }
        
        if
            let expiredAt = trade.expiredAt,
            !timeoutTimerRun {

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                guard let trade = self.trade else {
                    return
                }
                
                let timeout = expiredAt.timeIntervalSince1970 - Date().timeIntervalSince1970 //- createdAt.timeIntervalSince1970
                guard trade.status == .toBeCreated || trade.status == .unpaid else {
                    self.contentView.timeoutLabel.text = nil
                    timer.invalidate()
                    return
                }

                guard timeout > 0 else {
                    timer.invalidate()
                    self.showTimeoutAlert()
                    return
                }
                
                self.contentView.timeoutLabel.text = String(format: "Offer expires in: %@", timeout.formatted())
                self.contentView.timeoutLabel.boldSubstring("Offer expires in:")
            }.fire()
            
            timeoutTimerRun = true
        }
        
        updateID(with: trade.id)
        updateAmount(with: amount)
//        updateMinAmount(with: trade.min)
//        updateMaxAmount(with: trade.max)
        updateAddress(with: trade.inputAddress)
        updateQR(address: trade.inputAddress, paymentID: trade.paymentId, amount: trade.value)
        updateTrade(trade: trade)
        let _amount = "\(amount.formatted()) \(amount.currency.formatted())"
        let resultDescription: String
        
        if trade.inputCurrency == store.state.walletState.walletType.currency {
            let name = store.state.walletState.name
            resultDescription = String(format: NSLocalizedString("exchange_result_confirm_text", comment: ""), _amount, name)
                + "\n\n"
                + NSLocalizedString("exchange_result_confirm_sending", comment: "")
        } else {
            resultDescription = String(format: NSLocalizedString("exchange_result_description_text", comment: ""), _amount)
        }
        
        if !sent {
            contentView.confirmButton.isHidden = trade.inputCurrency != store.state.walletState.walletType.currency
            contentView.confirmButton.flex.markDirty()
        }
        
        description += " \n\n\n\n"
        description += "*" + NSLocalizedString("exchange_result_write_down_trade_id", comment: "")
        
        if let paymentId = trade.paymentId {
            contentView.paymentIDTitle.text = "Payment ID: "
            contentView.paymentIDTitle.boldSubstring("Payment ID:")
            contentView.paymentIDTitle.flex.markDirty()
            contentView.paymentIDLabel.text = paymentId
            contentView.paymentIDLabel.flex.markDirty()
            contentView.paymentIDRow.flex.layout()
        }
        
        if trade.status == .timeout {
            showTimeoutAlert()
        }
        
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
    
    private func showTimeoutAlert() {
        let okAction = CWAlertAction(title:  NSLocalizedString("Ok", comment: "")) { [weak self] action in
            action.alertView?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        showInfo(title: "Timeout", message: "Trade timed out", actions: [okAction])
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
            + ": " + MoneroAmountParser.formatValue(description.fee.value)
        
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
        let transactionID: String
        
        if
            let moneroPendingTransaction = pendingTransaction as? MoneroPendingTransaction,
            let _transactionID = moneroPendingTransaction.id {
            transactionID = _transactionID
        } else {
            transactionID = ""
        }
        
        showSpinner(withTitle: NSLocalizedString("creating_transaction", comment: "")) { [weak self, transactionID] alert in
            self?.store.dispatch(
                WalletActions.commit(
                    transaction: pendingTransaction,
                    handler: { result in
                        alert.dismiss(animated: true) {
                            switch result {
                            case .success(_):
                                self?.onTransactionCommited()

                                if let tradeID = self?.trade!.id {
                                    try? ExchangeTransactions.shared.add(
                                        tradeID: tradeID,
                                        transactionID: transactionID)
                                }
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
                        let address = self?.store.state.exchangeState.trade?.inputAddress
                        else { return }
                    let amount: Amount
                    
                    if let _amount = self?.trade?.value {
                        amount = _amount
                    } else if let _amount = self?.amount {
                        amount = _amount
                    } else {
                        return
                    }
                    
                    
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
