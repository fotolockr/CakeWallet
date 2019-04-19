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
        return Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in self?.fetchOrderDetails() }
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
        
        let qrCode = QRCode(orderDetails.address)
        contentView.qrImage.image = qrCode?.image
        
        contentView.copyButton.addTarget(self, action: #selector(onCopyAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
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
        UIPasteboard.general.string = contentView.addressLabel.text
        showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
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
            let expectedPin = json["pinInfo"]["pin"].string
            
            if let this = self {
                let alertConfirmAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    let selectCategoryViewController = BitrefillSelectCategoryViewController(
                        bitrefillFlow: this.bitrefillFlow,
                        categories: [],
                        products: []
                    )
                    this.navigationController?.pushViewController(selectCategoryViewController, animated: true)
                })
                
                
                if paymentReceived {
                    this.paymentReceived = true
                    this.contentView.timerLabel.text = "Received ✅"
                }
                
                if sent {
                    this.contentView.timerLabel.text = "Received and sent ✅ ✅"
                }
                
                if delivered {
                    this.checkOrderStatus.invalidate()
                    this.contentView.mainTitleLabel.text = "Success!"
                    this.contentView.mainTitleLabel.textColor = UIColor(red: 27, green: 183, blue: 30)
                    this.contentView.secondaryTitleLabel.text = "Order details have been sent to your email"
                    
                    if let pin = expectedPin {
                        this.contentView.addressLabel.text = pin
                        this.contentView.copyButton.setTitle("Copy voucher code", for: .normal)
                        
                        self?.contentView.qrCodeHolder.flex.height(0).width(0).markDirty()
                        self?.contentView.qrImage.flex.height(0).width(0).markDirty()
                        self?.contentView.rootFlexContainer.flex.layout()
                        self?.contentView.qrImage.isHidden = true

                        this.showOKInfoAlert(
                            title: "Bitrefill",
                            message: "Your payment for \(this.orderDetails.summary) has been successfully delivered. You can find voucher code on the screen and in your email."
                        )

                        return
                    }

                    this.showInfoAlert(
                        title: "Bitrefill",
                        message: "Your payment for \(this.orderDetails.summary) has been successfully delivered",
                        actions: [alertConfirmAction]
                    )
                }
                
                if this.seconds == 0 {
                    this.checkOrderStatus.invalidate()
                    this.showInfoAlert(
                        title: "Bitrefill",
                        message: "Payment has been expired",
                        actions: [alertConfirmAction]
                    )
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
