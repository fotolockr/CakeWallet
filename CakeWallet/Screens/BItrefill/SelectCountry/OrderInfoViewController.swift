import UIKit
import QRCode


final class BitrefillOrderInfoViewController: BaseViewController<BitrefillOrderInfoView> {
    let orderInfo: BitrefillOrderInfo
    // TODO: hardcoded value
    var seconds = 900
    
    init(orderInfo: BitrefillOrderInfo) {
        self.orderInfo = orderInfo
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Order info"
        
        // TODO: hardcoded currency
        contentView.priceLabel.text = "Amount: \(BitcoinAmount(value: orderInfo.satoshiPrice).formatted()) BTC"
        contentView.addressLabel.text = "To address: \(orderInfo.address)"
        
        contentView.summaryLabel.text = orderInfo.summary
        
//        let uri = MoneroUri(address: address, paymentId: paymentId, amount: amount)
        let qrCode = QRCode(orderInfo.address)
        
        contentView.qrImage.image = qrCode?.image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimer() {
        if seconds > 0 {
            seconds -= 1
            contentView.timerLabel.text = "Expiring in \(timeString(time: seconds))"
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
