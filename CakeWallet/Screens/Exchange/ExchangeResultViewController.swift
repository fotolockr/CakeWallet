import UIKit
import CakeWalletCore
import CakeWalletLib
import QRCode
import CWMonero
import RxSwift
import RxCocoa
import RxBiBinding

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



final class ExchangeResultViewController: BaseViewController<ExchangeResultView> {
    let amount: Amount
    private var trade: BehaviorRelay<Trade>
    private var sent: Bool
    private var timeoutTimerRun: Bool = false
    private lazy var updateTradeStateTimer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
            self?.updateTrade()
        }
    }()
    
    private let disposeBag: DisposeBag
    
    init(trade: Trade, amount: Amount) {
        self.trade = BehaviorRelay(value: trade)
        self.amount = amount
        self.sent = false
        disposeBag = DisposeBag()
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
        
        let tradeObserver = trade.asObservable()
        
        tradeObserver.subscribe(onNext: { [weak self] trade in
                if let xmrtotrade = trade as? XMRTOTrade {
                    self?.updateInfoAbout(trade: xmrtotrade)
                    return
                }
            
                self?.updateGeneralInfoAbout(trade: trade)
            }).disposed(by: disposeBag)
        
        tradeObserver
            .filter { $0.provider == .xmrto }
            .subscribe(onNext: { [weak self] trade in
                guard trade.state == .timeout || trade.state == .btcSent else {
                    return
                }

                self?.updateTradeStateTimer.invalidate()
        }).disposed(by: disposeBag)
        
        tradeObserver
            .filter { $0.provider != .xmrto }
            .subscribe(onNext: { [weak self] trade in
                guard trade.state == .complete else {
                    return
                }
                
                self?.updateTradeStateTimer.invalidate()
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTrade()
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
    
    func updateAddress(with address: String) {
        contentView.addressLabel.text = address
        contentView.addressLabel.flex.markDirty()
    }
    
    func updateQR(address: String, paymentID: String? = nil, amount: Amount? = nil) {
        let text: String
        
        if store.state.walletState.walletType.currency == trade.value.from {
            let uri = MoneroUri(address: address, paymentId: paymentID, amount: amount)
            text = uri.formatted()
        } else {
            text = address
        }
        
        contentView.qrImageView.image = QRCode(text)?.image
    }
    
    func updateTradeStatus(trade: Trade) {
        if
            case .btcSent = trade.state,
            let outputTxID = trade.outputTransaction {
            contentView.btcTxIDLabel.text = "Output transaction ID:"
            contentView.btcTxIDLabel.boldSubstring("Output transaction ID:")
            contentView.btcTxIDLabel.flex.markDirty()
            contentView.btcTxIDTextLabel.text = outputTxID
            contentView.btcTxIDTextLabel.flex.markDirty()
        }
        
        contentView.btcTxIDRow.flex.width(contentView.infoColumn.frame.size.width).layout()
        contentView.statusLabel.text = String(format: "%@: %@", NSLocalizedString("status", comment: ""), trade.state.formatted())
        contentView.statusLabel.boldSubstring(NSLocalizedString("status", comment: ""))
        contentView.statusLabel.flex.markDirty()
    }
    
    func updateGeneralInfoAbout(trade: Trade) {
        var description = ""
        
        updateID(with: trade.id)
        updateAmount(with: trade.amount)
        updateAddress(with: trade.inputAddress)
        updateQR(address: trade.inputAddress, paymentID: trade.extraId, amount: trade.amount)
        updateTradeStatus(trade: trade)
        
        if !sent {
            contentView.confirmButton.isHidden = trade.from != store.state.walletState.walletType.currency
            contentView.confirmButton.flex.markDirty()
        }
        
        description += " \n\n\n\n"
        description += "*" + NSLocalizedString("exchange_result_write_down_trade_id", comment: "")
        
        if let paymentId = trade.extraId {
            contentView.paymentIDTitle.text = "Payment ID: "
            contentView.paymentIDTitle.boldSubstring("Payment ID:")
            contentView.paymentIDTitle.flex.markDirty()
            contentView.paymentIDLabel.text = paymentId
            contentView.paymentIDLabel.flex.markDirty()
            contentView.paymentIDRow.flex.layout()
        }
        
        let resultDescription: String
        
        if trade.from == store.state.walletState.walletType.currency {
            let name = store.state.walletState.name
            resultDescription = String(
                format: "%@\n\n%@",
                String(format: NSLocalizedString("exchange_result_confirm_text", comment: ""), trade.amount.formatted(), name),
                NSLocalizedString("exchange_result_confirm_sending", comment: ""))
        } else {
            resultDescription = String(format: NSLocalizedString("exchange_result_description_text", comment: ""), trade.amount.formatted())
        }
        
        if let paymentId = trade.extraId {
            contentView.paymentIDTitle.text = "Payment ID: "
            contentView.paymentIDTitle.boldSubstring("Payment ID:")
            contentView.paymentIDTitle.flex.markDirty()
            contentView.paymentIDLabel.text = paymentId
            contentView.paymentIDLabel.flex.markDirty()
            contentView.paymentIDRow.flex.layout()
        }
        
        contentView.resultDescriptionLabel.text = resultDescription
        contentView.resultDescriptionLabel.flex.markDirty()
        contentView.descriptionTextView.text = description
        contentView.descriptionTextView.flex.markDirty()
        contentView.cardView.flex.markDirty()
        contentView.rootFlexContainer.flex.layout(mode: .adjustHeight)
        contentView.layoutSubviews()
    }
    
    func updateInfoAbout(trade: XMRTOTrade) {
        if
            let expiredAt = trade.expiredAt,
            !timeoutTimerRun {

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let trade = self?.trade.value else {
                    return
                }
                
                let timeout = expiredAt.timeIntervalSince1970 - Date().timeIntervalSince1970 //- createdAt.timeIntervalSince1970
                guard trade.state == .toBeCreated || trade.state == .unpaid else {
                    self?.contentView.timeoutLabel.text = nil
                    timer.invalidate()
                    return
                }

                guard timeout > 0 else {
                    timer.invalidate()
                    self?.showTimeoutAlert()
                    return
                }
                
                self?.contentView.timeoutLabel.text = String(format: "Offer expires in: %@", timeout.formatted())
                self?.contentView.timeoutLabel.boldSubstring("Offer expires in:")
            }.fire()
            
            timeoutTimerRun = true
        }
        
        if trade.state == .timeout {
            showTimeoutAlert()
        }
        
        updateGeneralInfoAbout(trade: trade)
    }
    
    @objc
    private func copyAddress() {
        UIPasteboard.general.string = trade.value.inputAddress
    }
    
    @objc
    private func copyId() {
        UIPasteboard.general.string = trade.value.id
    }
    
    @objc
    private func confirm() {
        guard trade.value.from == store.state.walletState.walletType.currency else {
            return
        }
        
        createTransaction()
    }
    
    private func updateTrade() {
        trade.value.update().bind(to: trade).disposed(by: disposeBag)
    }
    
    private func showTimeoutAlert() {
        let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        showInfoAlert(title: "Timeout", message: "Trade timed out", actions: [okAction])
    }
    
    private func onTransactionCreating() {
        let sendAction = UIAlertAction(title: NSLocalizedString("send", comment: ""), style: .default) { [weak self] _ in
            self?.createTransaction()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        showInfoAlert(
            title: NSLocalizedString("creating_transaction", comment: ""),
            message: NSLocalizedString("confirm_sending", comment: ""),
            actions: [cancelAction, sendAction]
        )
    }
    
    private func onTransactionCreated(_ pendingTransaction: PendingTransaction) {
        let description = pendingTransaction.description
        let message = NSLocalizedString("commit_transaction", comment:  "")
            + "\n" + NSLocalizedString("amount", comment: "")
            + ": " + description.amount.formatted()
            + "\n" + NSLocalizedString("fee", comment: "")
            + ": " + MoneroAmountParser.formatValue(description.fee.value)
        
        
        let commitAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { [weak self] _ in
            self?.commit(pendingTransaction: pendingTransaction)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            store.dispatch(TransactionsState.Action.changedSendingStage(.none))
        }
        
        showInfoAlert(title: NSLocalizedString("confirm_sending", comment: ""), message: message, actions: [cancelAction, commitAction])
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
        
        showSpinnerAlert(withTitle: NSLocalizedString("creating_transaction", comment: "")) { [weak self, transactionID] alert in
            store.dispatch(
                WalletActions.commit(
                    transaction: pendingTransaction,
                    handler: { result in
                        alert.dismiss(animated: true) {
                            switch result {
                            case .success(_):
                                self?.onTransactionCommited()

                                if let tradeID = self?.trade.value.id {
                                    try? ExchangeTransactions.shared.add(
                                        tradeID: tradeID,
                                        transactionID: transactionID)
                                }
                            case let .failed(error):
                                self?.showErrorAlert(error: error)
                                break
                            }
                        }
                })
            )
        }
    }
    
    private func onTransactionCommited() {
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { [weak self] _ in
            self?.contentView.confirmButton.isHidden = true
            self?.sent = true
        }
        
        showInfoAlert(title: NSLocalizedString("transaction_created", comment: ""), actions: [okAction])
    }
    
    private func createTransaction(_ handler: (() -> Void)? = nil) {
        let authController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        let navController = UINavigationController(rootViewController: authController)
        authController.handler = { [weak self] in
            authController.dismiss(animated: true) {
                self?.showSpinnerAlert(withTitle: NSLocalizedString("creating_transaction", comment: ""), callback: { alert in
                    guard let xmrtotrade = self?.trade.value as? XMRTOTrade else {
                        return
                    }
                    let priority = store.state.settingsState.transactionPriority
                    let address = xmrtotrade.inputAddress
                    let amount = xmrtotrade.amount
                    let paymentID = xmrtotrade.extraId ?? ""
                    
                    store.dispatch(
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
                                        self?.showErrorAlert(error: error)
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
