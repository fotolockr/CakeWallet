import UIKit
import QRCode
import Alamofire
import SwiftyJSON


struct BitrefillOrderDetails: JSONInitializable {
    let id: String
    let summary: String
    let address: String
    let satoshiPrice: Int
    let BIP21: String?
    let altcoinCode: String?
    let altcoinPrice: String?
    let expirationTime: Int64
    var withAltcoinCode: Bool?
    
    init(json: JSON) {
        id = json["id"].stringValue
        summary = json["summary"].stringValue
        address = json["payment"]["address"].stringValue
        satoshiPrice = json["payment"]["satoshiPrice"].intValue
        BIP21 = json["payment"]["BIP21"].stringValue
        altcoinCode = json["payment"]["altcoinCode"].stringValue
        altcoinPrice = json["payment"]["altcoinPrice"].stringValue
        expirationTime = json["expirationTime"].int64Value
    }
}


final class BitrefillOrderViewController: BaseViewController<BitrefillOrderView> {
    weak var bitrefillFlow: BitrefillFlow?
    let orderDetails: BitrefillOrderDetails
    
    var paymentReceived: Bool = false
    var seconds = 900
    
    var btcAmount: BitcoinAmount {
        return BitcoinAmount(value: orderDetails.satoshiPrice)
    }
    private lazy var checkOrderStatus: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in self?.fetchOrderDetails() }
    }()
    
    init(bitrefillFlow: BitrefillFlow?, orderDetails: BitrefillOrderDetails) {
        self.bitrefillFlow = bitrefillFlow
        self.orderDetails = orderDetails
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Order details"
        checkOrderStatus.fire()
        
        contentView.priceLabel.text = defineAmountLabel()
        contentView.addressLabel.text = orderDetails.address
        contentView.summaryLabel.text = orderDetails.summary
        
        // TODO: qrCode with amount?
        let qrCode = QRCode(orderDetails.address)
        contentView.qrImage.image = qrCode?.image
        
        contentView.copyButton.addTarget(self, action: #selector(onCopyAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // TODO: rename timer as labelTimer or smth
        contentView.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimer() {
        if !paymentReceived {
            if seconds > 0 {
                seconds -= 1
                contentView.timerLabel.text = "Expiring in \(timeString(time: seconds))"
            }
        }
    }
    
    @objc
    func onCopyAction() {
        UIPasteboard.general.string = orderDetails.address
    }
    
    func timeString(time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func fetchOrderDetails() {
        // sensitive  data? / duplicating
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
            let expired = json["expired"].boolValue
            
            if let this = self {
                if paymentReceived {
                    this.paymentReceived = true
                    this.contentView.timerLabel.text = "Payment received ✅"
                }
                
                if sent {
                    this.contentView.timerLabel.text = "Payment received and sent ✅ ✅"
                }
                
                if delivered {
                    this.checkOrderStatus.invalidate()
                    
                    // TODO: use actions from common alerts
                    let alertController = UIAlertController(
                        title: "Bitrefill",
                        message: "Your payment for \(this.orderDetails.summary) has been successfully delivered",
                        preferredStyle: .alert
                    )
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        let selectCategoryViewController = BitrefillSelectCategoryViewController(bitrefillFlow: this.bitrefillFlow, categories: [], products: [])
                        this.navigationController?.pushViewController(selectCategoryViewController, animated: true)
                    }))
                    
                    this.present(alertController, animated: true, completion: nil)
                }
                
                // TODO: use actions from common alerts
                if expired {
                    let alertController = UIAlertController(title: "Payment has been expired", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        let selectCategoryViewController = BitrefillSelectCategoryViewController(bitrefillFlow: self?.bitrefillFlow, categories: [], products: [])
                        this.navigationController?.pushViewController(selectCategoryViewController, animated: true)
                    }))
                    
                    this.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    private func defineAmountLabel () -> String {
        if let withAltcoinPrice = orderDetails.withAltcoinCode,
           let altcoinPrice = orderDetails.altcoinPrice,
           let altcoinCode = orderDetails.altcoinCode{
            
            if withAltcoinPrice {
                return "Amount: \(altcoinPrice) \(altcoinCode)"
            }
        }
        
        if let withBIP21String = orderDetails.BIP21 {
            let segments = withBIP21String.split { $0 == "=" }
            
            return "Amount: \(segments[segments.count - 1]) BTC"
        }
        
        return ""
    }
}
