import UIKit
import SwiftyJSON
import Alamofire


final class BitrefillProductDetailsViewController: BaseViewController<BitrefillProductDetailsView>, UIPickerViewDelegate, UIPickerViewDataSource {
    struct ProductPaymentRange: JSONInitializable {
        let min: Int
        let max: Int
        
        init(json: JSON) {
            min = json["min"].intValue
            max = json["max"].intValue
        }
    }
    
    struct ProductPackage: JSONInitializable {
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
    
    enum ProductPaymentMethod {
        case monero, lightning, lightningLtc, bitcoin, ethereum, litecoin, dash, dogecoin
        
        static var all: [ProductPaymentMethod] {
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
    
    struct Order: JSONRepresentable {
        let operatorSlug: String
        let valuePackage: String
        let email: String
        let paymentMethod: String
        var phoneNumber: String
        
        func makeJSON() throws -> JSON {
            return JSON([
                "operatorSlug": operatorSlug,
                "valuePackage": valuePackage,
                "email": email,
                "paymentMethod": paymentMethod,
                "number": phoneNumber
            ])
        }
    }
    
    weak var bitrefillFlow: BitrefillFlow?
    var productDetails: BitrefillProduct
    
    var productPaymentRange: ProductPaymentRange?
    var selectedPaymentMethod: ProductPaymentMethod
    
    var productPackages: [ProductPackage]?
    var selectedOrderPackage: String?
    
    init(bitrefillFlow: BitrefillFlow?, productDetails: BitrefillProduct) {
        self.bitrefillFlow = bitrefillFlow
        self.productDetails = productDetails
        
        selectedPaymentMethod = .monero
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        title = "Order"
        
        contentView.productName.text = productDetails.name
        contentView.amountPickerView.delegate = self
        contentView.amountPickerView.dataSource = self
        contentView.paymentMethodPickerView.delegate = self
        contentView.paymentMethodPickerView.dataSource = self
        
        contentView.submitButton.addTarget(self, action: #selector(onPayAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if productDetails.recipientType != "phone_number" {
            contentView.phoneNumerTextField.isHidden = true
            contentView.phoneNumerTextField.flex.height(0)
            contentView.flex.layout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProductDetails(for: productDetails.slug)
    }
    
    func fetchProductDetails(for productSlug: String) {
        let url = "https://www.bitrefill.com/api/widget/product/\(productSlug)"
        
        Alamofire.request(url, method: .get).responseData(completionHandler: { [weak self] response in
            guard
                let data = response.data,
                let json = try? JSON(data: data) else {
                    return
            }
            
            guard response.response?.statusCode == 200 else {
                if response.response?.statusCode == 400 {
                    self?.showOKInfoAlert(
                        title: "Couldn't fetch product details",
                        message: json["message"].stringValue
                    )
                }
                
                return
            }
            
            if let isRanged = self?.productDetails.isRanged {
                if isRanged {
                    let orderRangeJSON = json["range"]

                    self?.productPaymentRange = ProductPaymentRange(json: orderRangeJSON)

                    if let orderMinLimit = self?.productPaymentRange?.min,
                       let orderMaxLimit = self?.productPaymentRange?.max,
                       let currency = self?.productDetails.currency {
                        self?.contentView.minLimitLabel.text = "Min: \(orderMinLimit) \(currency)"
                        self?.contentView.maxLimitLabel.text = "Max: \(orderMaxLimit) \(currency)"
                    }

                    return
                }

                self?.contentView.limitsHolder.flex.height(0).markDirty()
                self?.contentView.flex.layout()
            }
            
            self?.contentView.amountTextField.textField.inputView = self?.contentView.amountPickerView
            
            let orderPackagesJSON = json["packages"]
            self?.productPackages = orderPackagesJSON.map({ ProductPackage(json: $1) })
            self?.contentView.amountPickerView.reloadAllComponents()
            
            self?.contentView.amountTextField.textField.text = "\(self?.productPackages?[0].value ?? "") \(self?.productDetails.currency ?? "")"
            self?.selectedOrderPackage = self?.productPackages?[0].value
        })
    }
    
    @objc
    func onPayAction() {
        if let email = contentView.emailTextField.textField.text,
            let phoneNumber = contentView.phoneNumerTextField.textField.text,
            let amountRange = contentView.amountTextField.textField.text {
            
            if productDetails.isRanged && amountRange.count == 0 {
                showOKInfoAlert(title: "Amount value is empty")
                return
            }
            
            if productDetails.recipientType == "phone_number" && phoneNumber.count == 0 {
                showOKInfoAlert(title: "Phone number is empty")
                return
            }
            
            if email.count == 0 {
                showOKInfoAlert(title: "Email address is empty")
                return
            }
            
            do {
                let order = Order(
                    operatorSlug: productDetails.slug,
                    valuePackage: productDetails.isRanged ? amountRange : selectedOrderPackage ?? "",
                    email: email,
                    // TODO: hardcoded payment method
                    paymentMethod: "bitcoin",
                    phoneNumber: phoneNumber
                )

                let orderJSON = try order.makeJSON()
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

                    let orderDetails = BitrefillOrderDetails(json: json)
                    self?.bitrefillFlow?.change(route: .order(orderDetails))
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
            if let packages = productPackages {
                return packages.count
            }
        }
        
        if pickerView.tag == 60 {
            return ProductPaymentMethod.all.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 50 {
            return "\(productPackages?[row].value ?? "") \(productDetails.currency)"
        }
        
        if pickerView.tag == 60 {
            return ProductPaymentMethod.all[row].optionFullName()
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 50 {
            contentView.amountTextField.textField.text = "\(productPackages?[row].value ?? "") \(productDetails.currency)"
            selectedOrderPackage = productPackages?[row].value
        }
        
        if pickerView.tag == 60 {
            contentView.paymentMethodTextField.textField.text = ProductPaymentMethod.all[row].optionFullName()
            selectedPaymentMethod = ProductPaymentMethod.all[row]
        }
    }
}
