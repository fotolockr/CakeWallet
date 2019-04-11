import UIKit
import SwiftyJSON
import Alamofire


struct BitrefillOrder {
    var operatorSlug: String
    var isRanged: Bool
    var valuePackage: String = ""
    var email: String = ""
    var paymentMethod: String = ""
    var refund_address: String = ""
    var recipientType: String
    var number: String? = ""
    var orderRange: BitrefillOrderRange?
    var currency: String
    
    init(operatorSlug: String, isRanged: Bool, recipientType: String, currency: String) {
        self.operatorSlug = operatorSlug
        self.isRanged = isRanged
        self.recipientType = recipientType
        self.currency = currency
    }
}


struct BitrefillOrderPackage {
    let value: String
    let eurPrice: Float
    let usdPrice: Float
    let satoshiPrice: BitcoinAmount
}


struct BitrefillOrderRange: JSONInitializable {
    let min: Int
    let max: Int
    
    init(json: JSON) {
        min = json["min"].intValue
        max = json["max"].intValue
    }
}


enum BitrefillPaymentMethod {
    case monero, lightning, lightningLtc, bitcoin, ethereum, litecoin, dash, dogecoin
    
    static var all: [BitrefillPaymentMethod] {
        return [.monero, .lightning, .lightningLtc, .bitcoin, .ethereum, .litecoin, .dash, .dogecoin]
    }
    
    func optionFullName() -> String {
        switch self {
        case .monero: return "Monero (xmr -> btc)"
        case .lightning: return "Lightning"
        case .lightningLtc: return "Lightning LTC"
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .litecoin: return "Litecoin"
        case .dash: return "Dash"
        case .dogecoin: return "Dogecoin"
        }
    }
}


final class BitrefillOrderViewController: BaseViewController<BitrefillOrderView>, UIPickerViewDelegate, UIPickerViewDataSource {
    var order: BitrefillOrder
    var selectedPaymentMethod: BitrefillPaymentMethod
    
    init(order: BitrefillOrder) {
        self.order = order
        selectedPaymentMethod = .monero
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
//        contentView.amountPickerView.delegate = self
//        contentView.amountPickerView.dataSource = self
        
        contentView.paymentMethodPickerView.delegate = self
        contentView.paymentMethodPickerView.dataSource = self
        
        title = "Order"
        contentView.amountTextField.textField.text = order.valuePackage
        contentView.payButton.addTarget(self, action: #selector(onPayAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProductDetails(for: "kyivstar-ukraine")
    }
    
    func fetchProductDetails(for productSlug: String) {
        let url = "https://www.bitrefill.com/api/widget/product/\(productSlug)"
        
        Alamofire.request(url, method: .get).responseData(completionHandler: { [weak self] response in
            guard let data = response.data else { return }
            
            if let isRanged = self?.order.isRanged {
                if isRanged {
                    let orderRangeJSON = JSON(data)["range"]
                    
                    self?.order.orderRange = BitrefillOrderRange(json: orderRangeJSON)
                    
                    if let orderMinLimit = self?.order.orderRange?.min,
                       let orderMaxLimit = self?.order.orderRange?.max,
                       let currency = self?.order.currency {
                        self?.contentView.minLimitLabel.text = "Min: \(orderMinLimit) \(currency)"
                        self?.contentView.maxLimitLabel.text = "Max: \(orderMaxLimit) \(currency)"
                    }
                    
                    return
                }
                
                self?.contentView.limitsHolder.flex.height(0).markDirty()
                self?.contentView.flex.layout()
            }
        })
    }
    
    @objc
    func onPayAction() {
        print(order)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 60 {
            return BitrefillPaymentMethod.all.count
        }
        
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 60 {
            return BitrefillPaymentMethod.all[row].optionFullName()
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 60 {
            contentView.paymentMethodTextField.textField.text = BitrefillPaymentMethod.all[row].optionFullName()
        }
    }
}
