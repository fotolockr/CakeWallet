import UIKit
import QRCode
import Alamofire
import SwiftyJSON
import CakeWalletCore
import CakeWalletLib


final class BitrefillMoneroOrderViewController: BaseViewController<BitrefillMoneroOrderView> {
    let store: Store<ApplicationState>
    let trade: ExchangeTrade
    let orderDetails: BitrefillOrderDetails
    
    private lazy var checkOrderStatus: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in self?.fetchOrderDetails() }
    }()
    
    init(store: Store<ApplicationState>, trade: ExchangeTrade, orderDetails: BitrefillOrderDetails) {
        self.store = store
        self.trade = trade
        self.orderDetails = orderDetails
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        setDescriptionString()
        contentView.summaryLabel.text = orderDetails.summary
        contentView.confirmButton.addTarget(self, action: #selector(onAcceptAction), for: .touchUpInside)
        
        let onVaucherCodeTapGesture = UITapGestureRecognizer(target: self, action: #selector(onVaucherCodeTapHandler))
        contentView.statusLabel.addGestureRecognizer(onVaucherCodeTapGesture)
    }
    
    @objc
    func onVaucherCodeTapHandler() {
        UIPasteboard.general.string = contentView.statusLabel.text
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
    }
    
    @objc
    func onAcceptAction() {
        contentView.statusLabel.text = "Status: confirmation..."
        
        contentView.confirmButton.showLoading()
        checkOrderStatus.fire()
        sendTransaction()
    }
    
    // TODO: reuse fetching logic
    func fetchOrderDetails() {
        let user = "cDNiFIIuUnIMVgdF"
        let password = "wpobccrxZaJlKQzB"
        
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        
        let url = URLComponents(string: "https://api.bitrefill.com/v1/order/\(orderDetails.id)")!
        var request = URLRequest(url: url.url!)
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        Alamofire.request(request).responseData(completionHandler: { [weak self] response in
            guard
                let data = response.data,
                let json = try? JSON(data: data) else {
                    return
            }
            
            guard response.response?.statusCode == 200 else { return }
            
            let paymentReceived = json["paymentReceived"].boolValue
            let sent = json["sent"].boolValue
            let delivered = json["delivered"].boolValue
            let expectedPin = json["pinInfo"]["pin"].string
            
            if let this = self {
                if paymentReceived {
                    this.contentView.statusLabel.text = "Status: received ✅"
                }
                
                if sent {
                    this.contentView.statusLabel.text = "Status: received and sent ✅ ✅"
                }
                
                if delivered {
                    this.contentView.confirmButton.hideLoading()
                    this.contentView.confirmButton.isEnabled = false
                    this.contentView.confirmButton.isHidden = true
                    
                    this.checkOrderStatus.invalidate()
                    this.contentView.mainTitleLabel.text = "XMR Payment success!"
                    this.contentView.mainTitleLabel.textColor = UIColor(red: 27, green: 183, blue: 30)

                    if let pin = expectedPin {
                        this.contentView.statusLabel.isUserInteractionEnabled = true
                        this.contentView.statusLabel.text = pin
                        
                        return
                    }
                }
            }
        })
    }
    
    private func sendTransaction() {
        store.dispatch(
            WalletActions.send(
                amount: trade.value,
                toAddres: trade.inputAddress,
                paymentID: "",
                priority: store.state.settingsState.transactionPriority,
                handler: { [weak self] result in
                    switch result {
                    case let .success(pendingTransaction):
                        self?.store.dispatch(
                            WalletActions.commit(
                                transaction: pendingTransaction,
                                handler: { result in
                                    switch result {
                                    case .success(_):
                                        return
                                    case let .failed(error):
                                        DispatchQueue.main.async {
                                            self?.contentView.confirmButton.hideLoading()
                                            self?.showErrorAlert(error: error)
                                        }
                                    }
                                }
                            )
                        )
                        
                    case let .failed(error):
                        DispatchQueue.main.async {
                            self?.contentView.confirmButton.hideLoading()
                            self?.showErrorAlert(error: error)
                        }
                    }
                }
            )
        )
    }
    
    private func setDescriptionString(){
        let walletName = store.state.walletState.name
        let bitcoinAmount = BitcoinAmount(value: orderDetails.satoshiPrice).formatted()
        guard let moneroAmount = trade.value?.formatted() else {
            return
        }
        
        let descriptionString =  """
        By submitting this order, you are converting \(moneroAmount) XMR from your wallet (\(walletName)) to \(bitcoinAmount) BTC and sending to the address below. This exchange is being handled by xmr.to
        """
        
        let descriptionTitleAttributedString = NSMutableAttributedString(string: descriptionString)
        let descriptionTitleParagraphStyle = NSMutableParagraphStyle()
        
        descriptionTitleParagraphStyle.lineSpacing = 4.5
        descriptionTitleAttributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: descriptionTitleParagraphStyle,
            range: NSMakeRange(0, descriptionTitleAttributedString.length)
        )
        contentView.descriptionTitleLabel.attributedText = descriptionTitleAttributedString
    }
}
