import UIKit
import QRCode
import SwiftyJSON


struct BitrefillOrderDetails: JSONInitializable {
    let summary: String
    let address: String
    let satoshiPrice: Int
    let altcoinCode: String?
    let altcoinPrice: String?
    let expirationTime: Int64
    var withAltcoinCode: Bool?
    
    init(json: JSON) {
        summary = json["summary"].stringValue
        address = json["payment"]["address"].stringValue
        satoshiPrice = json["payment"]["satoshiPrice"].intValue
        altcoinCode = json["payment"]["altcoinCode"].stringValue
        altcoinPrice = json["payment"]["altcoinPrice"].stringValue
        expirationTime = json["expirationTime"].int64Value
    }
}

final class BitrefillOrderViewController: BaseViewController<BitrefillOrderView> {
    let orderDetails: BitrefillOrderDetails
    var seconds = 900 // TODO: hardcoded value
    
    init(orderDetails: BitrefillOrderDetails) {
        self.orderDetails = orderDetails
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Order details"
        
        contentView.priceLabel.text = defineAmountLabel()
        contentView.addressLabel.text = "To address: \(orderDetails.address)"
        
        contentView.summaryLabel.text = orderDetails.summary
        
        let qrCode = QRCode(orderDetails.address)
        
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
    
    private func defineAmountLabel () -> String {
        if let withAltcoinPrice = orderDetails.withAltcoinCode,
           let altcoinPrice = orderDetails.altcoinPrice,
           let altcoinCode = orderDetails.altcoinCode{
            
            if withAltcoinPrice {
                return "Amount: \(altcoinPrice) \(altcoinCode)"
            }
        }
        
        return "Amount: \(BitcoinAmount(value: orderDetails.satoshiPrice).formatted()) BTC"
    }
}
