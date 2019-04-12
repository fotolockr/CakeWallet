import UIKit
import SwiftyJSON
import Alamofire


struct BitrefillOrder {
    var name: String
    var operatorSlug: String
    var isRanged: Bool
    var valuePackage: String = ""
    var email: String = ""
    var paymentMethod: String = ""
    var refund_address: String = ""
    var recipientType: String
    var number: String? = ""
    var orderRange: BitrefillOrderRange?
    var orderPackages: [BitrefillOrderPackage]?
    var currency: String
    
    init(name: String, operatorSlug: String, isRanged: Bool, recipientType: String, currency: String) {
        self.name = name
        self.operatorSlug = operatorSlug
        self.isRanged = isRanged
        self.recipientType = recipientType
        self.currency = currency
    }
}


struct FinalBitrefillOrder: JSONRepresentable {
    let operatorSlug: String
    let valuePackage: String
    let email: String
    let paymentMethod: String
    var phoneNumber: String
//    var refundAddress: String?
    
    func makeJSON() throws -> JSON {
        return JSON([
            "operatorSlug": operatorSlug,
            "valuePackage": valuePackage,
            "email": email,
            "paymentMethod": paymentMethod,
            "number": phoneNumber,
            // TODO: refund address
//            "refund_address": refundAddress
        ])
    }
}


// TODO: rename
struct BitrefillOrderInfo: JSONInitializable {
    let summary: String
    let address: String
    let satoshiPrice: Int
    let expirationTime: Int64
    
    init(json: JSON) {
        summary = json["summary"].stringValue
        address = json["payment"]["address"].stringValue
        // TODO: fixed bound with bitcoin
        satoshiPrice = json["payment"]["satoshiPrice"].intValue
        expirationTime = json["expirationTime"].int64Value
    }
}


struct BitrefillOrderPackage: JSONInitializable {
    let value: String
    let eurPrice: Float
    let usdPrice: Float
    let satoshiPrice: BitcoinAmount
    
    init(json: JSON) {
        value = json["value"].stringValue
        eurPrice = json["eurPrice"].floatValue
        usdPrice = json["usdPrice"].floatValue 
        satoshiPrice = BitcoinAmount(value: json["satoshiPrice"].uInt64Value)
    }
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
        case .monero: return "Monero (XMR -> BTC)"
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
    weak var bitrefillFlow: BitrefillFlow?
    var order: BitrefillOrder
    var selectedPaymentMethod: BitrefillPaymentMethod
    var orderPackages: [BitrefillOrderPackage]?
    var selectedOrderPackage: String?
    
    init(bitrefillFlow: BitrefillFlow?, order: BitrefillOrder) {
        self.bitrefillFlow = bitrefillFlow
        self.order = order
        selectedPaymentMethod = .monero
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Order"
        
        contentView.productName.text = order.name
        contentView.amountPickerView.delegate = self
        contentView.amountPickerView.dataSource = self
        contentView.paymentMethodPickerView.delegate = self
        contentView.paymentMethodPickerView.dataSource = self
        
        contentView.amountTextField.textField.text = order.valuePackage
        contentView.submitButton.addTarget(self, action: #selector(onPayAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if order.recipientType != "phone_number" {
            contentView.phoneNumerTextField.isHidden = true
            contentView.phoneNumerTextField.flex.height(0)
            contentView.flex.layout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProductDetails(for: order.operatorSlug)
    }
    
    // TODO: slipt with separate functions (move to -> ?)
    func fetchProductDetails(for productSlug: String) {
        let url = "https://www.bitrefill.com/api/widget/product/\(productSlug)"
        
        // TODO: failure handler
//        if let error = response.error {
//            handler(.failed(error))
//            return
//        }
        
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
            
            self?.contentView.amountTextField.textField.inputView = self?.contentView.amountPickerView
            
            let orderPackagesJSON = JSON(data)["packages"]
            self?.orderPackages = orderPackagesJSON.map({ BitrefillOrderPackage(json: $1) })
            self?.contentView.amountPickerView.reloadAllComponents()
            
            self?.contentView.amountTextField.textField.text = "\(self?.orderPackages?[0].value ?? "") \(self?.order.currency ?? "")"
            self?.selectedOrderPackage = self?.orderPackages?[0].value
        })
    }
    
    @objc
    func onPayAction() {
        if let email = contentView.emailTextField.textField.text,
            let phoneNumber = contentView.phoneNumerTextField.textField.text,
            let amountRange = contentView.amountTextField.textField.text {
            
            if order.isRanged && amountRange.count == 0 {
                showOKInfoAlert(title: "Amount value is empty")
                return
            }
            
            if order.recipientType == "phone_number" && phoneNumber.count == 0 {
                showOKInfoAlert(title: "Phone number is empty")
                return
            }
            
            if email.count == 0 {
                showOKInfoAlert(title: "Email address is empty")
                return
            }
            
            do {
                let finalOrderData = FinalBitrefillOrder(
                    operatorSlug: order.operatorSlug,
                    valuePackage: order.isRanged ? amountRange : selectedOrderPackage ?? "",
                    email: email,
                    // TODO: hardcoded payment method
                    paymentMethod: "bitcoin",
                    phoneNumber: phoneNumber
                )
                
                let orderJSON = try finalOrderData.makeJSON()
                let user = "cDNiFIIuUnIMVgdF"
                let password = "wpobccrxZaJlKQzB"
                let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
                let base64Credentials = credentialData.base64EncodedString()
                let url = URLComponents(string: "https://api.bitrefill.com/v1/order")!
                
                var request = URLRequest(url: url.url!)
                request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try orderJSON.rawData()
                
                contentView.submitButton.showLoading()
                
                Alamofire.request(request).responseJSON { [weak self] response in
                    self?.contentView.submitButton.hideLoading()
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data) else {
                            return
                    }
                    
                    guard response.response?.statusCode == 200 else {
                        if response.response?.statusCode == 400 {
                            self?.showOKInfoAlert(title: json["message"].stringValue)
                        }
                        
                        return
                    }
                    
                    let orderInfo = BitrefillOrderInfo(json: json)
                    self?.bitrefillFlow?.change(route: .orderInfo(orderInfo))
                }
            } catch {
                showErrorAlert(error: error)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 50 {
            if let packages = orderPackages {
                return packages.count
            }
        }
        
        if pickerView.tag == 60 {
            return BitrefillPaymentMethod.all.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 50 {
            return "\(orderPackages?[row].value ?? "") \(order.currency)"
        }
        
        if pickerView.tag == 60 {
            return BitrefillPaymentMethod.all[row].optionFullName()
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 50 {
            contentView.amountTextField.textField.text = "\(orderPackages?[row].value ?? "") \(order.currency)"
            selectedOrderPackage = orderPackages?[row].value
        }
        
        if pickerView.tag == 60 {
            contentView.paymentMethodTextField.textField.text = BitrefillPaymentMethod.all[row].optionFullName()
            selectedPaymentMethod = BitrefillPaymentMethod.all[row]
        }
    }
    
    // TODO
    private func formattedPackageTitle(for selectedPackage: Int?) -> String {
        return ""
    }
}
