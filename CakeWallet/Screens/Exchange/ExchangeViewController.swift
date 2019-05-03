import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout
import Starscream
import SwiftyJSON
import Alamofire
import CWMonero
import RxSwift
import RxCocoa
import RxBiBinding

// fixme!!!

private let morphTokenUri = "https://api.morphtoken.com"
private let xmrtoUri = "https://xmr.to/api/v2/xmr2btc"
private let cakeUserAgent = "CakeWallet/XMR iOS"

struct ExchangeOutput {
    let address: String
    let weight: Int
    let crypto: CryptoCurrency
}

public enum ExchangeTradeState: String, Formatted {
    case pending, confirming, processing, trading, traded, complete
    case toBeCreated, unpaid, underpaid, paidUnconfirmed, paid, btcSent, timeout, notFound
    case created, finished
    
    init?(fromChangenow value: String) {
        let _value = value.lowercased()
        
        switch _value {
        case "finished":
            self = .finished
        case "created":
            self = .created
        default:
            return nil
        }
    }
    
    init?(fromXMRTO value: String) {
        let _value = value.uppercased()
        
        switch _value {
        case "TO_BE_CREATED":
            self = .toBeCreated
        case "UNPAID":
            self = .unpaid
        case "UNDERPAID":
            self = .underpaid
        case "PAID_UNCONFIRMED":
            self = .paidUnconfirmed
        case "PAID":
            self = .paid
        case "BTC_SENT":
            self = .btcSent
        case "TIMED_OUT":
            self = .timeout
        case "NOT_FOUND":
            self = .notFound
        default:
            return nil
        }
    }
    
    public func formatted() -> String {
        switch self {
        case .toBeCreated:
            return "To be created"
        case .unpaid:
            return "Unpaid"
        case .underpaid:
            return "Under paid"
        case .paidUnconfirmed:
            return "Paid unconfirmed"
        case .paid:
            return "Paid"
        case .btcSent:
            return "BTC sent"
        case .timeout:
            return "Time out"
        case .notFound:
            return "Not found"
        case .finished:
            return "Finished"
        case .created:
            return "Created"
        default:
            let prefix = "exchange_trade_state_"
            return NSLocalizedString(prefix + self.rawValue, comment: "")
        }
    }
}

public enum ExchangeProvider {
    case morph, xmrto, changenow
}

extension ExchangeProvider: Formatted {
    public func formatted() -> String {
        switch self {
        case .morph:
            return "Morph"
        case .xmrto:
            return "XMR.TO"
        case .changenow:
            return "ChangeNow"
        }
    }
}

public struct ExchangeTrade: Equatable {
    public static func == (lhs: ExchangeTrade, rhs: ExchangeTrade) -> Bool {
        return lhs.id == rhs.id
            && lhs.inputCurrency == rhs.inputCurrency
            && lhs.outputCurrency == rhs.outputCurrency
            && lhs.inputAddress == rhs.inputAddress
            && lhs.min.compare(with: rhs.min)
            && lhs.max.compare(with: rhs.max)
            && lhs.status == rhs.status
            && lhs.provider == rhs.provider
            && lhs.timeout == rhs.timeout
    }
    
    public let id: String
    public let inputCurrency: CryptoCurrency
    public let outputCurrency: CryptoCurrency
    public let inputAddress: String
    public let min: Amount
    public let max: Amount
    public let value: Amount?
    public let status: ExchangeTradeState
    public let paymentId: String?
    public let provider: ExchangeProvider
    public let timeout: Int?
    public let outputTxID: String?
    public let createdAt: Date?
    public let expiredAt: Date?
    
    public init(
        id: String,
        inputCurrency: CryptoCurrency,
        outputCurrency: CryptoCurrency,
        inputAddress: String,
        min: Amount,
        max: Amount,
        value: Amount? = nil,
        status: ExchangeTradeState,
        paymentId: String? = nil,
        provider: ExchangeProvider,
        timeout: Int? = nil,
        outputTxID: String? = nil,
        createdAt: Date? = nil,
        expiredAt: Date? = nil) {
        self.id = id
        self.inputCurrency = inputCurrency
        self.outputCurrency = outputCurrency
        self.inputAddress = inputAddress
        self.min = min
        self.max = max
        self.value = value
        self.status = status
        self.paymentId = paymentId
        self.provider = provider
        self.timeout = timeout
        self.outputTxID = outputTxID
        self.createdAt = createdAt
        self.expiredAt = expiredAt
    }
}

enum ExchangerError: Error {
    case credentialsFailed(String)
    case tradeNotFould(String)
    case limitsNotFoud
    case tradeNotCreated
    case incorrectOutputAddress
}

extension ExchangerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .credentialsFailed(reason):
            return reason
        case .tradeNotFould(_):
            return NSLocalizedString("trade_not_found", comment: "")
        case .limitsNotFoud:
            return "" // fix me
        case .tradeNotCreated:
            return "Trade not created"
        case .incorrectOutputAddress:
            return "Inccorrect output address"
        }
    }
}

//final class ExchangeActionCreators {
//    static let shared = ExchangeActionCreators()
//    private static let ref = "cakewallet"
//    
//    func fetchRates() -> Store<ApplicationState>.AsyncActionProducer {
//        return { state, store, handler in
//            exchangeQueue.async {
//                let url =  URLComponents(string: "\(morphTokenUri)/rates")!
//                var request = URLRequest(url: url.url!)
//                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                Alamofire.request(request).responseData(completionHandler: { response in
//                    if let error = response.error {
//                        handler(ApplicationState.Action.changedError(error))
//                        return
//                    }
//                    
//                    guard
//                        let data = response.data,
//                        let json = try? JSON(data: data),
//                        let ticker = json["data"].dictionaryObject as? [String: [String: String]] else {
//                            return
//                    }
//                    
//                    var _rates = ticker.reduce([CryptoCurrency : [CryptoCurrency : Double]](), { generalResult, val -> [CryptoCurrency : [CryptoCurrency : Double]] in
//                        guard let crypto = CryptoCurrency(from: val.key) else {
//                            return generalResult
//                        }
//                        
//                        var _generalResult = generalResult
//                        let values = val.value.reduce([CryptoCurrency : Double](), { (result, val) -> [CryptoCurrency : Double] in
//                            guard let key = CryptoCurrency(from: val.key) else {
//                                return result
//                            }
//                            
//                            var _result = result
//                            let rate = Double(val.value)
//                            _result[key] = rate
//                            return _result
//                        })
//                        
//                        _generalResult[crypto] = values
//                        return _generalResult
//                    })
//                    
//                    _rates[.bitcoin]?[.monero] = nil
//                    store.dispatch(ExchangeState.Action.changedRate(_rates))
//                })
//                
//                self.fetchRatesForXMRTO()
//            }
//        }
//    }
//    
//    func fetchRatesForXMRTO() {
//        fetchPriceForXMRTO() { btcprice in
//            let price = 1 / btcprice
//            store.dispatch(ExchangeState.Action.changeRateOnlyFor(.bitcoin, .monero, price))
//        }
//    }
//    
//    func updateCurrentTradeState() -> Store<ApplicationState>.AsyncActionProducer {
//        return { state, store, handler in
//            exchangeQueue.async {
//                guard let trade = state.exchangeState.trade else {
//                    return
//                }
//                
//                let url =  URLComponents(string: "\(morphTokenUri)/morph/\(trade.id)")!
//                var request = URLRequest(url: url.url!)
//                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                Alamofire.request(request).responseData(completionHandler: { response in
//                    if let error = response.error {
//                        handler(ApplicationState.Action.changedError(error))
//                        return
//                    }
//                    
//                    guard
//                        let data = response.data,
//                        let json = try? JSON(data: data),
//                        let stateString = json["state"].string,
//                        let state = ExchangeTradeState(rawValue: stateString.lowercased()) else {
//                            handler(ApplicationState.Action.changedError(ExchangerError.tradeNotFould(trade.id)))
//                            return
//                    }
//                    
//                    let trade = ExchangeTrade(
//                        id: trade.id,
//                        inputCurrency: trade.inputCurrency,
//                        outputCurrency: trade.outputCurrency,
//                        inputAddress: trade.inputAddress,
//                        min: trade.min,
//                        max: trade.max,
//                        status: state,
//                        provider: .morph)
//                    
//                    handler(ExchangeState.Action.changedTrade(trade))
//                })
//            }
//        }
//    }
//    
//    func fetchPriceForXMRTO(handler: @escaping (Double) -> Void) {
//        exchangeQueue.async {
//            let url =  URLComponents(string: String(format: "%@/order_parameter_query/", xmrtoUri))!
//            var request = URLRequest(url: url.url!)
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            Alamofire.request(request).responseData(completionHandler: { response in
//                if let _ = response.error {
//                    //                        handler(ApplicationState.Action.changedError(error))
//                    return
//                }
//                
//                guard
//                    let data = response.data,
//                    let json = try? JSON(data: data),
//                    let btcprice = json["price"].double else {
//                        return
//                }
//                
//                handler(btcprice)
//            })
//        }
//    }
//    
//    func createTradeXMRTO(withMoneroAmount amount: Amount, address: String, handler: @escaping (CakeWalletLib.Result<String>) -> Void) {
//        fetchPriceForXMRTO() { price in
//            let doubleAmount = Double(amount.formatted()) ?? 0.0 as Double
//            let url =  URLComponents(string: String(format: "%@/order_create/", xmrtoUri))!
//            var request = URLRequest(url: url.url!)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
//            let btcAmount = doubleAmount * price
//            let bodyJSON: JSON = [
//                "btc_amount": String(btcAmount).replacingOccurrences(of: ",", with: "."),
//                "btc_dest_address": address
//            ]
//            
//            do {
//                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
//            } catch {
//                handler(.failed(error))
//                return
//            }
//            
//            Alamofire.request(request).responseData(completionHandler: { response in
//                if let error = response.error {
//                    handler(.failed(error))
//                    return
//                }
//                
//                guard
//                    let data = response.data,
//                    let json = try? JSON(data: data) else {
//                        return
//                }
//                
//                guard response.response?.statusCode == 201 else {
//                    if response.response?.statusCode == 400 {
//                        handler(.failed(ExchangerError.credentialsFailed(json["error_msg"].stringValue)))
//                    } else {
//                        handler(.failed(ExchangerError.tradeNotCreated))
//                    }
//                    
//                    return
//                }
//                
//                let uuid = json["uuid"].stringValue
//                handler(.success(uuid))
//            })
//            
//        }
//    }
//    
//    func createTradeXMRTO(amount: Amount, address: String, handler: @escaping (CakeWalletLib.Result<String>) -> Void) {
//        let url =  URLComponents(string: String(format: "%@/order_create/", xmrtoUri))!
//        var request = URLRequest(url: url.url!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
//        let bodyJSON: JSON = [
//            "btc_amount": amount.formatted().replacingOccurrences(of: ",", with: "."),
//            "btc_dest_address": address
//        ]
//        
//        do {
//            request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
//        } catch {
//            handler(.failed(error))
//            return
//        }
//        
//        Alamofire.request(request).responseData(completionHandler: { response in
//            if let error = response.error {
//                handler(.failed(error))
//                return
//            }
//            
//            guard
//                let data = response.data,
//                let json = try? JSON(data: data) else {
//                    return
//            }
//            
//            guard response.response?.statusCode == 201 else {
//                if response.response?.statusCode == 400 {
//                    handler(.failed(ExchangerError.credentialsFailed(json["error_msg"].stringValue)))
//                } else {
//                    handler(.failed(ExchangerError.tradeNotCreated))
//                }
//                
//                return
//            }
//            
//            let uuid = json["uuid"].stringValue
//            handler(.success(uuid))
//        })
//    }
//    
//    func getTradeForXMRTO(with uuid: String, handler: @escaping (CakeWalletLib.Result<ExchangeTrade>) -> Void) {
//        let url =  URLComponents(string: String(format: "%@/order_status_query/", xmrtoUri))!
//        var request = URLRequest(url: url.url!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
//        let bodyJSON: JSON = [
//            "uuid": uuid
//        ]
//        
//        do {
//            request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
//        } catch {
//            handler(.failed(error))
//            return
//        }
//        
//        Alamofire.request(request).responseData(completionHandler: { response in
//            if let error = response.error {
//                handler(.failed(error))
//                return
//            }
//            
//            guard response.response?.statusCode == 200 else {
//                return
//            }
//            
//            guard
//                let data = response.data,
//                let json = try? JSON(data: data) else {
//                    return
//            }
//            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//            
//            let address = json["xmr_receiving_integrated_address"].stringValue
//            let paymentId = json["xmr_required_payment_id_short"].stringValue
//            let totalAmount = json["xmr_amount_total"].stringValue
//            let amount = MoneroAmount(from: totalAmount)
//            let stateString = json["state"].stringValue
//            let state = ExchangeTradeState(fromXMRTO: stateString) ?? .notFound
//            var expiredAt: Date? // = Date(timeIntervalSince1970: expiredAtTimestamp)
//            
//            if let _expiredAt = dateFormatter.date(from: json["expires_at"].stringValue) {
//                expiredAt = _expiredAt
//            }
//            
//            let trade = ExchangeTrade(
//                id: uuid,
//                inputCurrency: .monero,
//                outputCurrency: .bitcoin,
//                inputAddress: address,
//                min: MoneroAmount(value: 0),
//                max: MoneroAmount(value: 0),
//                value: amount,
//                status: state,
//                paymentId: paymentId,
//                provider: .xmrto,
//                outputTxID: state == .btcSent
//                    ? json["btc_transaction_id"].stringValue
//                    : nil,
//                expiredAt: expiredAt
//            )
//            
//            handler(.success(trade))
//        })
//    }
//    
//    func getOrderStatusForXMRTO(uuid: String) -> Store<ApplicationState>.AsyncActionProducer {
//        return { state, store, handler in
//            self.getTradeForXMRTO(with: uuid, handler: { res in
//                switch res {
//                case let .success(trade):
//                    handler(ExchangeState.Action.changedTrade(trade))
//                case let .failed(error):
//                    handler(ApplicationState.Action.changedError(error))
//                }
//            })
//        }
//    }
//    
//    func createTrade(from input: CryptoCurrency, refund: String, outputs: [ExchangeOutput], handler: @escaping (CakeWalletLib.Result<ExchangeTrade>) -> Void) {
//        //        return { state, store, handler in
//        exchangeQueue.async {
//            let url =  URLComponents(string: "\(morphTokenUri)/morph")!
//            var request = URLRequest(url: url.url!)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            let bodyJSON: JSON = [
//                "input": [
//                    "asset": input.formatted(),
//                    "refund": refund
//                ],
//                "output": outputs.map({[
//                    "asset": $0.crypto.formatted(),
//                    "weight": $0.weight,
//                    "address": $0.address
//                    ]}),
//                "tag": ExchangeActionCreators.ref
//            ]
//            
//            do {
//                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
//            } catch {
//                handler(.failed(error))
//                return
//            }
//            
//            Alamofire.request(request).responseData(completionHandler: { response in
//                if let error = response.error {
//                    handler(.failed(error))
//                    return
//                }
//                
//                guard
//                    let data = response.data,
//                    let json = try? JSON(data: data) else {
//                        return
//                }
//                
//                if json["success"].exists() && !json["success"].boolValue {
//                    handler(.failed(ExchangerError.credentialsFailed(json["description"].stringValue)))
//                    
//                    return
//                }
//                
//                guard
//                    let depositAddress = json["input"]["deposit_address"].string,
//                    let id = json["id"].string,
//                    let minAmount = json["input"]["limits"]["min"].uInt64,
//                    let maxAmount = json["input"]["limits"]["max"].uInt64 else {
//                        return
//                }
//                
//                let min: Amount
//                let max: Amount
//                
//                switch input {
//                case .bitcoin:
//                    min = BitcoinAmount(value: minAmount)
//                    max = BitcoinAmount(value: maxAmount)
//                case .monero:
//                    min = MoneroAmount(value: UInt64(minAmount))
//                    max = MoneroAmount(value: UInt64(maxAmount))
//                case .bitcoinCash, .dash, .liteCoin:
//                    min = EDAmount(value: minAmount, currency: input)
//                    max = EDAmount(value: maxAmount, currency: input)
//                case .ethereum:
//                    min = EthereumAmount(value: minAmount)
//                    max = EthereumAmount(value: maxAmount)
//                }
//                
//                let trade = ExchangeTrade(
//                    id: id,
//                    inputCurrency: input,
//                    outputCurrency: outputs.first!.crypto,
//                    inputAddress: depositAddress,
//                    min: min,
//                    max: max,
//                    status: ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending,
//                    provider: .morph
//                )
//                
//                handler(.success(trade))
//            })
//        }
//    }
//    //    }
//}

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

typealias Limits = (min: UInt64, max: UInt64)

private func fetchLimits(for inputAsset: CryptoCurrency, and outputAsset: CryptoCurrency, outputWeight: Int = 10000, handler: @escaping (CakeWalletLib.Result<Limits>) -> Void) {
    exchangeQueue.async {
        let url =  URLComponents(string: "\(morphTokenUri)/limits")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        let intput: JSON = ["asset": inputAsset.formatted()]
        let output: JSON = ["asset": outputAsset.formatted(), "weight": outputWeight]
        let body: JSON = [
            "input" : intput,
            "output" : [output]
        ]
        request.httpBody = try? body.rawData()
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(request).responseData(completionHandler: { response in
            if let error = response.error {
                handler(.failed(error))
                return
            }
            
            guard
                let data = response.data,
                let json = try? JSON(data: data) else {
                    return
            }
            
            if
                let success = json["success"].bool,
                !success {
                handler(.failed(ExchangerError.limitsNotFoud))
                return
            }
            
            guard
                let min = json["input"]["limits"]["min"].uInt64,
                let max = json["input"]["limits"]["max"].uInt64
                else {
                    handler(.failed(ExchangerError.limitsNotFoud))
                    return
                    
            }
            
            let limits = Limits(min: min, max: max)
            handler(.success(limits))
        })
    }
}

private func fetchXMRTOLimits(handler: @escaping (CakeWalletLib.Result<(min: Double, max: Double)>) -> Void) {
    exchangeQueue.async {
        let url =  URLComponents(string: "\(xmrtoUri)/order_parameter_query")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(request).responseData(completionHandler: { response in
            if let error = response.error {
                handler(.failed(error))
                return
            }
            
            guard
                let data = response.data,
                let json = try? JSON(data: data) else {
                    return
            }
            
            guard
                let min = json["lower_limit"].double,
                let max = json["upper_limit"].double
                else {
                    handler(.failed(ExchangerError.limitsNotFoud))
                    return
            }
            
            let limits = (min: min, max: max)
            handler(.success(limits))
        })
    }
}

//func makeAmount(from stringAmount: String, for crypto: CryptoCurrency) -> Amount {
//    switch crypto {
//    case .bitcoin:
//        return BitcoinAmount(from: stringAmount)
//    case .bitcoinCash, .dash, .liteCoin:
//        return EDAmount(from: stringAmount, currency: crypto)
//    case .ethereum:
//        return EthereumAmount(from: stringAmount)
//    case .monero:
//        return MoneroAmount(from: stringAmount)
//    }
//}

//func makeAmount(from value: UInt64, for crypto: CryptoCurrency) -> Amount {
//    switch crypto {
//    case .bitcoin:
//        return BitcoinAmount(value: value)
//    case .bitcoinCash, .dash, .liteCoin:
//        return EDAmount(value: value, currency: crypto)
//    case .ethereum:
//        return EthereumAmount(value: value)
//    case .monero:
//        return MoneroAmount(value: value)
//    }
//}

final class ExchangeViewController: BaseViewController<ExchangeView>, StoreSubscriber, CurrencyPickerDelegate {
    weak var exchangeFlow: ExchangeFlow?
    
    let cryptos: [CryptoCurrency]
//    let exchangeActionCreators: ExchangeActionCreators
    let store: Store<ApplicationState>
    
    var depositAmount: Amount {
        let stringAmount = contentView.depositCardView.amountTextField.textField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        return makeAmount(stringAmount, currency: depositCrypto.value)
    }
    
    private var receiveAmount: Amount {
        get {
            let stringAmount = contentView.receiveCardView.amountTextField.textField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
            return makeAmount(stringAmount, currency: receiveCrypto.value)
        }
        
        set {
            contentView.receiveCardView.amountTextField.textField.text = newValue.formatted()
        }
    }
    
    private let receiveAmountString: BehaviorRelay<String>
    private let depositAmountString: BehaviorRelay<String>
    private let receiveAddress: BehaviorRelay<String>
    private let depositRefundAddress: BehaviorRelay<String>
    private let depositMinAmount: BehaviorRelay<String>
    private let depositMaxAmount: BehaviorRelay<String>
    private let receiveMinAmount: BehaviorRelay<String>
    private let receiveMaxAmount: BehaviorRelay<String>
    
    private let depositCrypto: BehaviorRelay<CryptoCurrency>
    private let receiveCrypto: BehaviorRelay<CryptoCurrency>
    
    private var didSetCurrentAddressForDeposit: Bool
    private var didSetCurrentAddressForReceive: Bool
    private var exchangeNameView: WalletNameView = WalletNameView()
    private var isXMRTO: Bool {
        return exchange.provider == .xmrto
    }
    
    private var exchange: AnyExchange = XMRTOExchange() {
        didSet {
            exchangeChanged()
        }
    }
    private let exchangeList: ExchangeList = ExchangeList()
    private let receiveLimits: BehaviorRelay<ExchangeLimits> = BehaviorRelay(value: (min: nil, max: nil))
    private let depositLimits: BehaviorRelay<ExchangeLimits> = BehaviorRelay(value: (min: nil, max: nil))
    private let disposeBag: DisposeBag
    
    init(store: Store<ApplicationState>, exchangeFlow: ExchangeFlow?) {
        cryptos = CryptoCurrency.all
//        exchangeActionCreators = ExchangeActionCreators.shared
        depositCrypto = BehaviorRelay<CryptoCurrency>(value: .monero)
        receiveCrypto = BehaviorRelay<CryptoCurrency>(value: .bitcoin)
        didSetCurrentAddressForDeposit = false
        didSetCurrentAddressForReceive = false
        disposeBag = DisposeBag()
        receiveAmountString = BehaviorRelay<String>(value: "")
        depositAmountString = BehaviorRelay<String>(value: "")
        receiveAddress = BehaviorRelay<String>(value: "")
        depositRefundAddress = BehaviorRelay<String>(value: "")
        depositMinAmount = BehaviorRelay<String>(value: "0.0")
        depositMaxAmount = BehaviorRelay<String>(value: "0.0")
        receiveMinAmount = BehaviorRelay<String>(value: "0.0")
        receiveMaxAmount = BehaviorRelay<String>(value: "0.0")
        self.exchangeFlow = exchangeFlow
        self.store = store
        super.init()
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "exchange_icon")?.resized(to: CGSize(width: 24, height: 28)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "exchange_icon_selected")?.resized(to: CGSize(width: 24, height: 28)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    @objc
    func onDepositPickerButtonTap() {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        
        let currencyPickerVC = CurrencyPickerViewController(selectedItem: depositCrypto.value)
        currencyPickerVC.type = .deposit
        currencyPickerVC.delegate = self
        currencyPickerVC.modalPresentationStyle = .overCurrentContext
        tabBarController?.present(currencyPickerVC, animated: true)
    }
    
    @objc
    func onReceivePickerButtonTap() {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        
        let currencyPickerVC = CurrencyPickerViewController(selectedItem: receiveCrypto.value)
        currencyPickerVC.type = .receive
        currencyPickerVC.delegate = self
        currencyPickerVC.modalPresentationStyle = .overCurrentContext
        tabBarController?.present(currencyPickerVC, animated: true)
    }
    
    private func showExchangeSelection() {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        let currentPair = Pair(from: depositCrypto.value, to: receiveCrypto.value, reverse: false)
        let providers = exchangeList.exchangeProviders(for: currentPair)
        let selectedProvider = exchange.provider
        let pickerVC = PickerViewController(items: providers, selectedItem: selectedProvider)
        pickerVC.pickerTitle = "Switch exchange"
        pickerVC.onPick = { provider in
            guard let exchange = self.exchangeList.exchange(for: provider) else {
                return
            }
            
            self.exchange = exchange
        }
        pickerVC.modalPresentationStyle = .overCurrentContext
        tabBarController?.present(pickerVC, animated: true)
    }
    
    override func configureBinds() {
        let receiveAmountObserver = receiveAmountString.asObservable()
        let depositAmountObserver = depositAmountString.asObservable()
        let receiveLimitsObserver = receiveLimits.asObservable()
        let depositLimitsObserver = depositLimits.asObservable()
        
        let depositOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDepositPickerButtonTap))
        contentView.depositCardView.pickerButtonView.addGestureRecognizer(depositOnTapGesture)
        
        let receiveOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onReceivePickerButtonTap))
        contentView.receiveCardView.pickerButtonView.addGestureRecognizer(receiveOnTapGesture)
        contentView.depositCardView.addressContainer.presenter = self
        contentView.depositCardView.addressContainer.updateResponsible = self
        contentView.receiveCardView.addressContainer.presenter = self
        contentView.receiveCardView.addressContainer.updateResponsible = self
        exchangeNameView.title = NSLocalizedString("exchange", comment: "")
        exchangeNameView.subtitle = exchange.provider.formatted()
        exchangeNameView.onTap = { [weak self] in
            self?.showExchangeSelection()
        }
        navigationItem.titleView = exchangeNameView
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Switch exchange", style: .plain, target: nil, action: nil)
//        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [weak self] _ in
//            self?.showExchangeSelection()
//        }).disposed(by: disposeBag)
        
        (contentView.receiveCardView.addressContainer.textView.originText <-> receiveAddress)
            .disposed(by: disposeBag)

        (contentView.depositCardView.addressContainer.textView.originText <-> depositRefundAddress)
            .disposed(by: disposeBag)
        
        (contentView.depositCardView.amountTextField.textField.rx.text.orEmpty <-> depositAmountString)
            .disposed(by: disposeBag)
        
        (contentView.receiveCardView.amountTextField.textField.rx.text.orEmpty <-> receiveAmountString)
            .disposed(by: disposeBag)
        
        let depositCryptoObserver = depositCrypto.asObservable()
        
        depositCryptoObserver
            .bind { self.onDepositCryptoChange($0) }
            .disposed(by: disposeBag)
        
        let receiveCryptoObserver = receiveCrypto.asObservable()
        
        Observable.combineLatest(depositCryptoObserver, receiveCryptoObserver)
            .subscribe(onNext: { [weak self] deposit, receive in self?.changeExchange(deposit: deposit, receive: receive) })
            .disposed(by: disposeBag)
        
        depositAmountObserver
            .filter { !$0.isEmpty }
            .map { Double($0.replacingOccurrences(of: ",", with: ".")) ?? 0 }
            .map { self.exchange.calculateAmount($0, from: self.depositCrypto.value, to: self.receiveCrypto.value) }
            .flatMap { $0 }
            .map { return $0.formatted() }
            .bind(to: contentView.receiveCardView.amountTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        depositAmountObserver
            .filter { $0.isEmpty }
            .map { _ in return nil }
            .bind(to: contentView.receiveCardView.amountTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        receiveAmountObserver
            .filter { !$0.isEmpty }
            .map { Double($0.replacingOccurrences(of: ",", with: ".")) ?? 0 }
            .map { self.exchange.calculateAmount($0, from: self.receiveCrypto.value, to: self.depositCrypto.value) }
            .flatMap { $0 }
            .map { return $0.formatted() }
            .bind(to: contentView.depositCardView.amountTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        receiveAmountObserver
            .filter { $0.isEmpty }
            .map { _ in return nil }
            .bind(to: contentView.depositCardView.amountTextField.textField.rx.text)
            .disposed(by: disposeBag)
        
        receiveCryptoObserver.bind {
            self.onReceiveCryptoChange($0)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(receiveLimitsObserver.map({ $0.max }), receiveCryptoObserver) { limit, currency -> String? in
                guard let limitFormatted = limit?.formatted() else {
                    return nil
                }
            
                return String(format: "%@: %@ %@", NSLocalizedString("max", comment: ""), limitFormatted, currency.formatted())
            }
            .bind(to: contentView.receiveCardView.maxLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(receiveLimitsObserver.map({ $0.min }), receiveCryptoObserver) { limit, currency -> String? in
            guard let limitFormatted = limit?.formatted() else {
                return nil
            }
            
            return String(format: "%@: %@ %@", NSLocalizedString("min", comment: ""), limitFormatted, currency.formatted())
            }
            .bind(to: contentView.receiveCardView.minLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(depositLimitsObserver.map({ $0.max }), depositCryptoObserver) { limit, currency -> String? in
            guard let limitFormatted = limit?.formatted() else {
                return nil
            }
            
            return String(format: "%@: %@ %@", NSLocalizedString("max", comment: ""), limitFormatted, currency.formatted())
            }
            .bind(to: contentView.depositCardView.maxLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(depositLimitsObserver.map({ $0.min }), depositCryptoObserver) { limit, currency -> String? in
            guard let limitFormatted = limit?.formatted() else {
                return nil
            }
            
            return String(format: "%@: %@ %@", NSLocalizedString("min", comment: ""), limitFormatted, currency.formatted())
            }
            .bind(to: contentView.depositCardView.minLabel.rx.text)
            .disposed(by: disposeBag)
        
        contentView.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        contentView.exchangeButton.addTarget(self, action: #selector(exhcnage), for: .touchUpInside)
        
        onDepositCryptoChange(depositCrypto.value)
        onReceiveCryptoChange(receiveCrypto.value)
        didSetCurrentAddressForDeposit = false
        didSetCurrentAddressForReceive = false
        setProviderTitle()
//        if isXMRTO() {
//            contentView.depositCardView.minLabel.isHidden = true
//            contentView.depositCardView.maxLabel.isHidden = true
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clearButton = UIBarButtonItem()
        clearButton.title = "Clear"
        clearButton.action = #selector(clear)
        
        clearButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .normal)
        clearButton.setTitleTextAttributes([
            NSAttributedStringKey.font: applyFont(ofSize: 16, weight: .regular),
            NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue], for: .highlighted)
        navigationItem.rightBarButtonItem = clearButton
        XMRTOExchange.asyncUpdateUri()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [
            \ApplicationState.exchangeState,
            \ApplicationState.walletState
            ])
//        store.dispatch(exchangeActionCreators.fetchRates()) {
//            //
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        highlightNeededFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func setTitle() {
        title = NSLocalizedString("exchange", comment: "")
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        changedWallet(type: state.walletState.walletType)
    }
    
    // MARK: CurrencyPickerDelegate
    
    func onPicked(item: CryptoCurrency, pickerType: ExchangeCardType) {
        switch pickerType {
        case .deposit:
            depositCrypto.accept(item)
        case .receive:
            receiveCrypto.accept(item)
        case .unknown:
            return
        }
    }
    
    private func exchangeChanged() {
        updateLimits()
        setProviderTitle()
        exchangeNameView.subtitle = exchange.provider.formatted()
        contentView.depositCardView.amountTextField.textField.isUserInteractionEnabled = !isXMRTO
        contentView.receiveCardView.amountTextField.textField.isUserInteractionEnabled = isXMRTO
        highlightNeededFields()
    }
    
    private func highlightNeededFields() {
        let isXMRTO = self.isXMRTO
        contentView.depositCardView.amountTextField.borderView.backgroundColor = !isXMRTO ? UIColor(red: 126, green: 92, blue: 250) : UIColor.veryLightBlue
        contentView.receiveCardView.amountTextField.borderView.backgroundColor = isXMRTO ? UIColor(red: 126, green: 92, blue: 250) : UIColor.veryLightBlue
    }
    
    private func changeExchange(deposit: CryptoCurrency, receive: CryptoCurrency) {
        let isReverse = deposit == .monero && receive == .bitcoin ? false : true
        
        if let exchange = exchangeList.exchange(for: Pair(from: deposit, to: receive, reverse: isReverse)) {
            self.exchange = exchange
        }
    }
    
    private func onDepositCryptoChange(_ crypto: CryptoCurrency) {
        contentView.depositCardView.pickerButtonView.pickedCurrency.text = crypto.formatted()
        
        if store.state.walletState.walletType.currency == crypto {
            contentView.depositCardView.pickerButtonView.walletNameLabel.text = store.state.walletState.name
            
            if !didSetCurrentAddressForDeposit {
                didSetCurrentAddressForDeposit = true
                contentView.depositCardView.addressContainer.textView.originText.accept(store.state.walletState.address)
            }
        } else {
            didSetCurrentAddressForDeposit = false
            contentView.depositCardView.pickerButtonView.walletNameLabel.text = nil
            contentView.depositCardView.addressContainer.textView.text = nil
        }
        
        let amount = Double(receiveAmountString.value) ?? 0
        exchange.calculateAmount(amount, from: crypto, to: receiveCrypto.value)
            .map { $0.formatted() }
            .bind(to: receiveAmountString)
            .disposed(by: disposeBag)
        
        
        
        
//        receiveAmountString.accept(receiveAmount)
//        contentView.receiveCardView.amountTextField.textField.text = receiveAmount
        setProviderTitle()
        updateLimits()
    }
    
    private func updateLimits() {
//        if isXMRTO() {
//            fetchXMRTOLimits() { [weak self] result in
//                DispatchQueue.main.async {
//                    guard let receiveCrypto = self?.receiveCrypto else {
//                        return
//                    }
//
//                    switch result {
//                    case let .success(limits):
//                        let min = makeAmount(from: String(limits.min), for: receiveCrypto.value)
//                        let max = makeAmount(from: String(limits.max), for: receiveCrypto.value)
//                        self?.receiveMinAmount.accept(min.formatted())
//                        self?.receiveMaxAmount.accept(max.formatted())
//                        self?.contentView.depositCardView.minLabel.isHidden = true
//                        self?.contentView.depositCardView.maxLabel.isHidden = true
//                    case let.failed(error):
//                        print(error)
//                    }
//                }
//            }
//            return
//        }
//
//        contentView.depositCardView.minLabel.isHidden = false
//        contentView.depositCardView.maxLabel.isHidden = false
        
        if isXMRTO {
            exchange.fetchLimist(from: receiveCrypto.value, to: depositCrypto.value)
                .bind(to: receiveLimits)
                .disposed(by: disposeBag)
        } else {
            exchange.fetchLimist(from: depositCrypto.value, to: receiveCrypto.value)
                .bind(to: depositLimits)
                .disposed(by: disposeBag)
        }
        
//        fetchLimits(for: receiveCrypto.value, and: depositCrypto.value) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let depositCrypto = self?.depositCrypto else {
//                    return
//                }
//
//                switch result {
//                case let .success(limits):
//                    let min = makeAmount(from: limits.min, for: depositCrypto.value)
//                    let max = makeAmount(from: limits.max, for: depositCrypto.value)
//                    self?.receiveMinAmount.accept(min.formatted())
//                    self?.receiveMaxAmount.accept(max.formatted())
//                case let.failed(error):
//                    print(error)
//                }
//            }
//        }
//
//        fetchLimits(for: depositCrypto.value, and: receiveCrypto.value) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let depositCrypto = self?.depositCrypto else {
//                    return
//                }
//
//                switch result {
//                case let .success(limits):
//                    let min = makeAmount(from: limits.min, for: depositCrypto.value)
//                    let max = makeAmount(from: limits.max, for: depositCrypto.value)
//                    self?.depositMaxAmount.accept(max.formatted())
//                    self?.depositMinAmount.accept(min.formatted())
//                case let.failed(error):
//                    print(error)
//                }
//            }
//        }
    }
    
    private func onReceiveCryptoChange(_ crypto: CryptoCurrency) {
        contentView.receiveCardView.pickerButtonView.pickedCurrency.text = crypto.formatted()
        
        if store.state.walletState.walletType.currency == crypto {
            contentView.receiveCardView.pickerButtonView.walletNameLabel.text = store.state.walletState.name
            
            if !didSetCurrentAddressForReceive {
                didSetCurrentAddressForReceive = true
                receiveAddress.accept(store.state.walletState.address)
//                contentView.receiveCardView.addressContainer.textView.change(text: store.state.walletState.address)
            }
        } else {
            didSetCurrentAddressForReceive = false
            contentView.receiveCardView.pickerButtonView.walletNameLabel.text = nil
            contentView.receiveCardView.addressContainer.textView.text = nil
        }
        
        setProviderTitle()
        updateLimits()
    }
    
    private func changedWallet(type: WalletType) {
        contentView.setNeedsLayout()
    }
    
    private func calculateAmount(forInput input: CryptoCurrency, output: CryptoCurrency, amount: String, rates: ExchangeRate) -> String {
        let rate = input == output
            ? 1
            : rates[input]?[output] ?? 0
        let formattedAmount = amount.replacingOccurrences(of: ",", with: ".")
        let result = rate * (Double(formattedAmount) ?? 0)
        let outputAmount: Amount
        
        switch receiveCrypto.value {
        case .bitcoin:
            outputAmount = BitcoinAmount(from: String(result))
        case .monero:
            outputAmount = MoneroAmount(from: String(result))
        case .bitcoinCash, .dash, .liteCoin:
            outputAmount = EDAmount(from: String(result), currency: output)
        case .ethereum:
            outputAmount = EthereumAmount(from: String(result))
        }
        
        //        return amountForDisplayFormatted(from: outputAmount.formatted())
        return outputAmount.formatted()
    }
    
    private func updateReceiveResult(with amount: Amount) {
        if
            let crypto = amount.currency as? CryptoCurrency,
            crypto == receiveCrypto.value {
            contentView.receiveCardView.receiveViewAmount.text = String(format: "%@ %@", amount.formatted(), receiveCrypto.value.formatted())
            return
        }
        
        let rate = depositCrypto.value == receiveCrypto.value
            ? 1
            :self.store.state.exchangeState.rates[depositCrypto.value]?[receiveCrypto.value] ?? 0
        let formattedAmount = amount.formatted().replacingOccurrences(of: ",", with: ".")
        let result = rate * (Double(formattedAmount) ?? 0)
        let outputAmount: Amount
        
        switch receiveCrypto.value {
        case .bitcoin:
            outputAmount = BitcoinAmount(from: String(result))
        case .monero:
            outputAmount = MoneroAmount(from: String(result))
        case .bitcoinCash, .dash, .liteCoin:
            outputAmount = EDAmount(from: String(result), currency: receiveCrypto.value)
        case .ethereum:
            outputAmount = EthereumAmount(from: String(result))
        }
        
        let formattedOutputAmount = amountForDisplayFormatted(from: outputAmount.formatted())
        contentView.receiveCardView.receiveViewAmount.text = String(format: "%@ %@", formattedOutputAmount, receiveCrypto.value.formatted())
    }
    
    private func setProviderTitle() {
        var title: String
        var icon: String
//        let isXMRTO = receiveCrypto.value == .bitcoin && depositCrypto.value == .monero
//
//        if isXMRTO {
//            title = "Powered by XMR.to"
//            icon = "xmr_to_logo"
//        }
        
        switch exchange.provider {
        case .changenow:
            title = "Powered by Changenow.io"
            icon = ""
        case .morph:
            title = "Powered by Morphtoken"
            icon = "xmr_to_logo"
        case .xmrto:
            title = "Powered by XMR.to"
            icon = "xmr_to_logo"
        }
        
        guard contentView.exchangeDescriptionLabel.text != title else {
            return
        }
        
        contentView.dispclaimerLabel.text = exchange.provider == .xmrto ? "The receive amount is guaranteed" : "The receive amount is an estimate."
        changeProviderTitle(title, icon: UIImage(named: icon))
    }
    
    private func changeProviderTitle(_ title: String, icon: UIImage? = nil) {
        contentView.exchangeDescriptionLabel.text =  title
        contentView.exchangeLogoImage.image = icon
        contentView.exchangeDescriptionLabel.flex.markDirty()
        contentView.descriptionView.flex.layout()
    }
    
    @objc
    private func clear() {
        contentView.depositCardView.amountTextField.textField.text = ""
        contentView.depositCardView.addressContainer.textView.text = ""
        
        contentView.receiveCardView.amountTextField.textField.text = ""
        contentView.receiveCardView.addressContainer.textView.text = ""
        updateReceiveResult(with: makeAmount(0 as UInt64, currency: receiveCrypto.value))
        store.dispatch(ExchangeState.Action.changedTrade(nil))
    }
    
    @objc
    private func exhcnage() {
        let refundAddress = store.state.walletState.walletType.currency == depositCrypto.value
            ? store.state.walletState.address
            : depositRefundAddress.value
        
        let outputAddress = store.state.walletState.walletType.currency == receiveCrypto.value
            ? store.state.walletState.address
            : receiveAddress.value
        
        guard !refundAddress.isEmpty else {
            showOKInfoAlert(message: NSLocalizedString("refund_address_is_empty", comment: ""))
            return
        }
        
        guard !outputAddress.isEmpty else {
            showOKInfoAlert(message: NSLocalizedString("receive_address_is_empty", comment: ""))
            return
        }
        
//        let output = ExchangeOutput(
//            address: outputAddress,
//            weight: 10000,
//            crypto: receiveCrypto.value)
//        let amount = isXMRTO() ? receiveAmount : depositAmount
        let amountString = (isXMRTO ? receiveAmountString.value : depositAmountString.value).replacingOccurrences(of: ",", with: ".")
        let amount = makeAmount(amountString, currency: isXMRTO ? receiveCrypto.value : depositCrypto.value)
        let request: TradeRequest
        
        switch exchange.provider {
        case .changenow:
            request = ChangeNowTradeRequest(
                from: depositCrypto.value,
                to: receiveCrypto.value,
                address: receiveAddress.value,
                amount: amountString,
                refundAddress: depositRefundAddress.value)
        case .morph:
            request = MorphTradeRequest(from: depositCrypto.value, to: receiveCrypto.value, refundAddress: receiveAddress.value, outputAdress: "")
        case .xmrto:
            request = XMRTOTradeRequest(amount: amount, address: receiveAddress.value)
        }
        
        showSpinnerAlert(withTitle: NSLocalizedString("create_exchange", comment: "")) { alert in
            self.exchange.createTrade(from: request)
                .subscribe(onNext: { trade in
                    alert.dismiss(animated: true) {
                        self.onTradeCreated(trade, amount: amount)
                    }
                }, onError: { error in
                    alert.dismiss(animated: true) {
                        self.showErrorAlert(error: error)
                    }
                }).disposed(by: self.disposeBag)
            
//            if self.isXMRTO() {
//                self.exchangeActionCreators.createTradeXMRTO(amount: amount, address: outputAddress) { result in
//                    alert.dismiss(animated: true) { [weak self] in
//                        guard let this = self else {
//                            return
//                        }
//
//                        switch result {
//                        case let .success(uuid):
//                            let alert = ExchangeAlertViewController()
//                            alert.onDone = {
//                                this.store.dispatch(
//                                    this.exchangeActionCreators.getOrderStatusForXMRTO(uuid: uuid)
//                                ) {
//                                    this.exchangeFlow?.change(route: .exchangeResult(amount))
//                                }
//                            }
//                            alert.setTradeID(uuid)
//                            self?.present(alert, animated: true)
//                        case let .failed(error):
//                            this.store.dispatch(ApplicationState.Action.changedError(error))
//                            this.showErrorAlert(error: error)
//                        }
//                    }
//                }
//                return
//            }
//
//            self.exchangeActionCreators.createTrade(
//                from: self.depositCrypto.value,
//                refund: refundAddress,
//                outputs: [output]
//            ) { result in
//                alert.dismiss(animated: true) { [weak self] in
//                    switch result {
//                    case let .success(trade):
//                        let alert = ExchangeAlertViewController()
//                        alert.onDone = {
//                            self?.store.dispatch(ExchangeState.Action.changedTrade(trade))
//                            self?.exchangeFlow?.change(route: .exchangeResult(amount))
//                        }
//                        alert.setTradeID(trade.id)
//                        self?.present(alert, animated: true)
//                    case let .failed(error):
//                        self?.store.dispatch(ApplicationState.Action.changedError(error))
//                        self?.showErrorAlert(error: error)
//                    }
//                }
//            }
        }
    }
    
    private func onTradeCreated(_ trade: Trade, amount: Amount) {
        let alert = ExchangeAlertViewController()
        alert.onDone = { [weak self] in
            self?.exchangeFlow?.change(route: .exchangeResult(trade, amount))
        }
        
        alert.setTradeID(trade.id)
        present(alert, animated: true)
    }
    
//    private func isXMRTO() -> Bool {
//        return receiveCrypto.value == .bitcoin && depositCrypto.value == .monero
//    }
}

extension ExchangeViewController: QRUriUpdateResponsible {
    func getCrypto(for addressView: AddressView) -> CryptoCurrency {
        return addressView.tag == 2000 ? depositCrypto.value : receiveCrypto.value
    }
    
    func updated(_ addressView: AddressView, withURI uri: QRUri) {
        guard let amount = uri.amount?.formatted() else {
            return
        }
        
        let amountReply = addressView.tag == 2000 ? depositAmountString : receiveAmountString
        amountReply.accept(amount)
    }
}


class ExchangeContentAlertView: BaseFlexView {
    let messageLabel: UILabel
    let copiedLabel: UILabel
    let copyButton: CopyButton
    
    required init() {
        messageLabel = UILabel()
        copiedLabel = UILabel(fontSize: 12)
        copyButton = CopyButton(title: NSLocalizedString("copy_id", comment: ""), fontSize: 14)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        copyButton.backgroundColor = .vividBlue
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = applyFont(ofSize: 16)
        copiedLabel.textAlignment = .center
        copiedLabel.textColor = .wildDarkBlue
        backgroundColor = .clear
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).backgroundColor(.clear).define { flex in
            flex.addItem(messageLabel).margin(UIEdgeInsets(top: 0, left: 30, bottom: 30, right: 30))
            flex.addItem(copiedLabel).height(10).marginBottom(5)
            flex.addItem(copyButton).height(56).marginBottom(20).width(80%).backgroundColor(UIColor(hex: 0x97E2FF))
        }
    }
    
    func setTradeID(_ id: String) {
        copyButton.textHandler = { [weak self] in
            self?.copied()
            return id
        }
        
        messageLabel.text = String(format: NSLocalizedString("please_save_sec_key", comment: ""), id)
        messageLabel.flex.markDirty()
        flex.layout()
    }
    
    private func copied() {
        copiedLabel.text = NSLocalizedString("copied", comment: "")
        copiedLabel.flex.markDirty()
        flex.layout()
    }
}

class ExchangeTransactions {
    static let shared: ExchangeTransactions = ExchangeTransactions()
    
    private static let name = "exchange_transactions.txt"
    
    private static var url: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    }
    
    private static func load() -> JSON {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSON(data: data) else {
                return JSON()
        }
        
        return json
    }
    
    private var json: JSON
    
    init() {
        json = ExchangeTransactions.load()
    }
    
    func getTradeID(by transactionID: String) -> String? {
        return json.array?.filter({ j -> Bool in
            return j["txID"].stringValue == transactionID
        }).first?["tradeID"].string
    }
    
    func add(tradeID: String, transactionID: String) throws {
        guard getTradeID(by: transactionID) == nil else {
            return
        }
        
        let item = JSON(["tradeID": tradeID, "txID": transactionID])
        let array = json.arrayValue + [item]
        json = JSON(array)
        try save()
    }
    
    private func save() throws {
        try json.rawData().write(to: ExchangeTransactions.url)
    }
}
