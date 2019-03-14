import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout
import Starscream
import SwiftyJSON
import Alamofire
import CWMonero

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
        default:
            let prefix = "exchange_trade_state_"
            return NSLocalizedString(prefix + self.rawValue, comment: "")
        }
    }
}

public enum ExchangeProvider {
    case morph, xmrto
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

final class ExchangeActionCreators {
    static let shared = ExchangeActionCreators()
    private static let ref = "cakewallet"
    
    func fetchRates() -> Store<ApplicationState>.AsyncActionProducer {
        return { state, store, handler in
            DispatchQueue.global(qos: .utility).async {
                let url =  URLComponents(string: "\(morphTokenUri)/rates")!
                var request = URLRequest(url: url.url!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                Alamofire.request(request).responseData(completionHandler: { response in
                    if let error = response.error {
                        handler(ApplicationState.Action.changedError(error))
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data),
                        let ticker = json["data"].dictionaryObject as? [String: [String: String]] else {
                            return
                    }
                    
                    var _rates = ticker.reduce([CryptoCurrency : [CryptoCurrency : Double]](), { generalResult, val -> [CryptoCurrency : [CryptoCurrency : Double]] in
                        guard let crypto = CryptoCurrency(from: val.key) else {
                            return generalResult
                        }

                        var _generalResult = generalResult
                        let values = val.value.reduce([CryptoCurrency : Double](), { (result, val) -> [CryptoCurrency : Double] in
                            guard let key = CryptoCurrency(from: val.key) else {
                                return result
                            }

                            var _result = result
                            let rate = Double(val.value)
                            _result[key] = rate
                            return _result
                        })

                        _generalResult[crypto] = values
                        return _generalResult
                    })
                    
                    _rates[.bitcoin]?[.monero] = nil
                    store.dispatch(ExchangeState.Action.changedRate(_rates))
                })
                
                self.fetchRatesForXMRTO()
            }
        }
    }
    
    func fetchRatesForXMRTO() {
        fetchPriceForXMRTO() { btcprice in
            let price = 1 / btcprice
            store.dispatch(ExchangeState.Action.changeRateOnlyFor(.bitcoin, .monero, price))
        }
    }
    
    func updateCurrentTradeState() -> Store<ApplicationState>.AsyncActionProducer {
        return { state, store, handler in
            DispatchQueue.global(qos: .utility).async {
                guard let trade = state.exchangeState.trade else {
                    return
                }
                
                let url =  URLComponents(string: "\(morphTokenUri)/morph/\(trade.id)")!
                var request = URLRequest(url: url.url!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                Alamofire.request(request).responseData(completionHandler: { response in
                    if let error = response.error {
                        handler(ApplicationState.Action.changedError(error))
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data),
                        let stateString = json["state"].string,
                        let state = ExchangeTradeState(rawValue: stateString.lowercased()) else {
                            handler(ApplicationState.Action.changedError(ExchangerError.tradeNotFould(trade.id)))
                            return
                    }
                    
                    let trade = ExchangeTrade(
                        id: trade.id,
                        inputCurrency: trade.inputCurrency,
                        outputCurrency: trade.outputCurrency,
                        inputAddress: trade.inputAddress,
                        min: trade.min,
                        max: trade.max,
                        status: state,
                        provider: .morph)
                    
                    handler(ExchangeState.Action.changedTrade(trade))
                })
            }
        }
    }
    
    func fetchPriceForXMRTO(handler: @escaping (Double) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let url =  URLComponents(string: String(format: "%@/order_parameter_query/", xmrtoUri))!
            var request = URLRequest(url: url.url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            Alamofire.request(request).responseData(completionHandler: { response in
                if let _ = response.error {
                    //                        handler(ApplicationState.Action.changedError(error))
                    return
                }
                
                guard
                    let data = response.data,
                    let json = try? JSON(data: data),
                    let btcprice = json["price"].double else {
                        return
                }
                
                handler(btcprice)
            })
        }
    }
    
    func createTradeXMRTO(withMoneroAmount amount: Amount, address: String, handler: @escaping (CakeWalletLib.Result<String>) -> Void) {
        fetchPriceForXMRTO() { price in
            let doubleAmount = Double(amount.formatted()) ?? 0.0 as Double
            let url =  URLComponents(string: String(format: "%@/order_create/", xmrtoUri))!
            var request = URLRequest(url: url.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
            let btcAmount = doubleAmount * price
            let bodyJSON: JSON = [
                "btc_amount": String(btcAmount).replacingOccurrences(of: ",", with: "."),
                "btc_dest_address": address
            ]
            
            do {
                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
            } catch {
                handler(.failed(error))
                return
            }
            
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
                
                guard response.response?.statusCode == 201 else {
                    if response.response?.statusCode == 400 {
                        handler(.failed(ExchangerError.credentialsFailed(json["error_msg"].stringValue)))
                    } else {
                        handler(.failed(ExchangerError.tradeNotCreated))
                    }
                    
                    return
                }
                
                let uuid = json["uuid"].stringValue
                handler(.success(uuid))
            })

        }
    }
    
    func createTradeXMRTO(amount: Amount, address: String, handler: @escaping (CakeWalletLib.Result<String>) -> Void) {
            let url =  URLComponents(string: String(format: "%@/order_create/", xmrtoUri))!
            var request = URLRequest(url: url.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
            let bodyJSON: JSON = [
                "btc_amount": amount.formatted().replacingOccurrences(of: ",", with: "."),
                "btc_dest_address": address
            ]

            do {
                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
            } catch {
                handler(.failed(error))
                return
            }
            
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

                guard response.response?.statusCode == 201 else {
                    if response.response?.statusCode == 400 {
                        handler(.failed(ExchangerError.credentialsFailed(json["error_msg"].stringValue)))
                    } else {
                        handler(.failed(ExchangerError.tradeNotCreated))
                    }
                    
                    return
                }
                
                let uuid = json["uuid"].stringValue
                handler(.success(uuid))
            })
    }
    
    func getOrderStatusForXMRTO(uuid: String) -> Store<ApplicationState>.AsyncActionProducer {
        return { state, store, handler in
            let url =  URLComponents(string: String(format: "%@/order_status_query/", xmrtoUri))!
            var request = URLRequest(url: url.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(cakeUserAgent, forHTTPHeaderField: "User-Agent")
            let bodyJSON: JSON = [
                "uuid": uuid
            ]
            
            do {
                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
            } catch {
                handler(ApplicationState.Action.changedError(error))
                return
            }
            
            Alamofire.request(request).responseData(completionHandler: { response in
                if let error = response.error {
                    handler(ApplicationState.Action.changedError(error))
                    return
                }
                
                guard response.response?.statusCode == 200 else {
                    return
                }
                
                guard
                    let data = response.data,
                    let json = try? JSON(data: data) else {
                        return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                
                
                let address = json["xmr_receiving_integrated_address"].stringValue
                let paymentId = json["xmr_required_payment_id_short"].stringValue
                let totalAmount = json["xmr_amount_total"].stringValue
                let amount = MoneroAmount(from: totalAmount)
                let stateString = json["state"].stringValue
                let state = ExchangeTradeState(fromXMRTO: stateString) ?? .notFound
                var expiredAt: Date? // = Date(timeIntervalSince1970: expiredAtTimestamp)
                
                if let _expiredAt = dateFormatter.date(from: json["expires_at"].stringValue) {
                    expiredAt = _expiredAt
                }
                
                let trade = ExchangeTrade(
                    id: uuid,
                    inputCurrency: .monero,
                    outputCurrency: .bitcoin,
                    inputAddress: address,
                    min: MoneroAmount(value: 0),
                    max: MoneroAmount(value: 0),
                    value: amount,
                    status: state,
                    paymentId: paymentId,
                    provider: .xmrto,
                    outputTxID: state == .btcSent
                        ? json["btc_transaction_id"].stringValue
                        : nil,
                    expiredAt: expiredAt
                )
                
                handler(ExchangeState.Action.changedTrade(trade))
            })
        }
    }
    
    func createTrade(from input: CryptoCurrency, refund: String, outputs: [ExchangeOutput], handler: @escaping (CakeWalletLib.Result<ExchangeTrade>) -> Void) {
//        return { state, store, handler in
            DispatchQueue.global(qos: .utility).async {
                let url =  URLComponents(string: "\(morphTokenUri)/morph")!
                var request = URLRequest(url: url.url!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let bodyJSON: JSON = [
                    "input": [
                        "asset": input.formatted(),
                        "refund": refund
                    ],
                    "output": outputs.map({[
                        "asset": $0.crypto.formatted(),
                        "weight": $0.weight,
                        "address": $0.address
                        ]}),
                    "tag": ExchangeActionCreators.ref
                ]
                
                do {
                    request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
                } catch {
                    handler(.failed(error))
                    return
                }
                
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
                                        
                    if json["success"].exists() && !json["success"].boolValue {
                        handler(.failed(ExchangerError.credentialsFailed(json["description"].stringValue)))
                        
                        return
                    }
                    
                    guard
                        let depositAddress = json["input"]["deposit_address"].string,
                        let id = json["id"].string,
                        let minAmount = json["input"]["limits"]["min"].uInt64,
                        let maxAmount = json["input"]["limits"]["max"].uInt64 else {
                            return
                    }

                    let min: Amount
                    let max: Amount
                    
                    switch input {
                    case .bitcoin:
                        min = BitcoinAmount(value: minAmount)
                        max = BitcoinAmount(value: maxAmount)
                    case .monero:
                        min = MoneroAmount(value: UInt64(minAmount))
                        max = MoneroAmount(value: UInt64(maxAmount))
                    case .bitcoinCash, .dash, .liteCoin:
                        min = EDAmount(value: minAmount, currency: input)
                        max = EDAmount(value: maxAmount, currency: input)
                    case .ethereum:
                        min = EthereumAmount(value: minAmount)
                        max = EthereumAmount(value: maxAmount)
                    }
                    
                    let trade = ExchangeTrade(
                        id: id,
                        inputCurrency: input,
                        outputCurrency: outputs.first!.crypto,
                        inputAddress: depositAddress,
                        min: min,
                        max: max,
                        status: ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending,
                        provider: .morph
                    )
                    
                    handler(.success(trade))
                })
            }
        }
//    }
}

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
    DispatchQueue.global(qos: .utility).async {
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
    DispatchQueue.global(qos: .utility).async {
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

func makeAmount(from stringAmount: String, for crypto: CryptoCurrency) -> Amount {
    switch crypto {
    case .bitcoin:
        return BitcoinAmount(from: stringAmount)
    case .bitcoinCash, .dash, .liteCoin:
        return EDAmount(from: stringAmount, currency: crypto)
    case .ethereum:
        return EthereumAmount(from: stringAmount)
    case .monero:
        return MoneroAmount(from: stringAmount)
    }
}

func makeAmount(from value: UInt64, for crypto: CryptoCurrency) -> Amount {
    switch crypto {
    case .bitcoin:
        return BitcoinAmount(value: value)
    case .bitcoinCash, .dash, .liteCoin:
        return EDAmount(value: value, currency: crypto)
    case .ethereum:
        return EthereumAmount(value: value)
    case .monero:
        return MoneroAmount(value: value)
    }
}

final class ExchangeViewController: BaseViewController<ExchangeView>, StoreSubscriber, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var exchangeFlow: ExchangeFlow?
    
    let cryptos: [CryptoCurrency]
    let exchangeActionCreators: ExchangeActionCreators
    let store: Store<ApplicationState>
    
    var depositAmount: Amount {
        let stringAmount = contentView.depositeCardView.amountTextField.textField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        return makeAmount(from: stringAmount, for: depositCrypto)
    }
    
    var depositRefund: String {
        return contentView.depositeCardView.addressTextField.textField.text ?? ""
    }
    
    var receiveAddress: String {
        return contentView.receiveCardView.addressTextField.textField.text ?? ""
    }
    
    private var receiveAmount: Amount?
    
    private(set) var depositCrypto: CryptoCurrency {
        didSet {
            onDepositCryptoChange(depositCrypto)
        }
    }
    
    private(set) var receiveCrypto: CryptoCurrency {
        didSet {
            onReceiveCryptoChange(receiveCrypto)
        }
    }
    
    private var minDepositAmount: Amount?
    private var maxDepositAmount: Amount?
    
    private var minReceiveAmount: Amount?
    private var maxReceiveAmount: Amount?
    
    init(store: Store<ApplicationState>, exchangeFlow: ExchangeFlow?) {
        cryptos = CryptoCurrency.all //.filter({ $0 != CryptoCurrency.bitcoinCash })
        exchangeActionCreators = ExchangeActionCreators.shared
        depositCrypto = .monero
        receiveCrypto = .bitcoin
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
    func tick1() {
        print("qrCodeButton 1")
    }
    
    @objc
    func tick2() {
        print("addressBookButton 2")
    }
    
    @objc
    func onDepositPickerButtonTap() {
        depositCrypto = depositCrypto == .bitcoin ? CryptoCurrency.monero : CryptoCurrency.bitcoin
    }
    
    override func configureBinds() {
        contentView.depositeCardView.addressTextField.qrCodeButton.addTarget(self, action: #selector(tick1), for: .touchUpInside)
        contentView.depositeCardView.addressTextField.addressBookButton.addTarget(self, action: #selector(tick2), for: .touchUpInside)
        let depositOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDepositPickerButtonTap))
        contentView.depositeCardView.pickerButton.addGestureRecognizer(depositOnTapGesture)
        
//        contentView.receiveView.addressContainer.textView.delegate = contentView
//        contentView.depositView.addressContainer.textView.delegate = contentView
//        contentView.depositView.addressContainer.presenter = self
//        contentView.receiveView.addressContainer.presenter = self
//
//        contentView.depositView.exchangePickerView.pickerView.dataSource = self
//        contentView.depositView.exchangePickerView.pickerView.delegate = self
//        contentView.depositView.exchangePickerView.pickerView.selectRow(cryptos.index(of: depositCrypto) ?? 0, inComponent: 0, animated: false)
//        onDepositCryptoChange(depositCrypto)
        contentView.depositeCardView.amountTextField.textField.addTarget(self, action: #selector(onDepositAmountChange(_:)), for: .editingChanged)
//        contentView.depositView.addressContainer.updateResponsible = self
//
//        contentView.receiveView.amountTextField.addTarget(self, action: #selector(onReceiveAmountChange(_:)), for: .editingChanged)
//        contentView.receiveView.addressContainer.updateResponsible = self
//
//        contentView.receiveView.exchangePickerView.pickerView.dataSource = self
//        contentView.receiveView.exchangePickerView.pickerView.delegate = self
//        contentView.receiveView.exchangePickerView.pickerView.selectRow(cryptos.index(of: receiveCrypto) ?? 0, inComponent: 0, animated: false)
//        contentView.receiveView.addressContainer.updateResponsible = self
//        onReceiveCryptoChange(receiveCrypto)
//        contentView.depositView.setupWallet(name: store.state.walletState.name)
//        updateLimits()
//
//        if depositCrypto != store.state.walletState.walletType.currency {
//            contentView.depositView.hideWalletName()
//        }
//
//        contentView.receiveView.setupWallet(name: store.state.walletState.name)
//
//        if receiveCrypto != store.state.walletState.walletType.currency {
//            contentView.receiveView.hideWalletName()
//        }
        
        contentView.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        contentView.exchangeButton.addTarget(self, action: #selector(exhcnage), for: .touchUpInside)
        setProviderTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self, onlyOnChange: [
            \ApplicationState.exchangeState,
            \ApplicationState.walletState
            ])
        store.dispatch(exchangeActionCreators.fetchRates()) {
            //
        }
        
        onDepositCryptoChange(depositCrypto)
        onReceiveCryptoChange(receiveCrypto)
        
        if let receiveAmount = receiveAmount {
            updateDepositAmount(receiveAmount)
        }
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
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.hideSelectionIndicator()
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cryptos.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard cryptos.count > row else { return nil }
        return cryptos[row].formatted()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return ExchangePickerItemView.rowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ExchangePickerItemView.rowWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard cryptos.count > row else { return UIView() }
        
        let _view = view as? ExchangePickerItemView ?? ExchangePickerItemView()
        _view.label.text = cryptos[row].formatted()
        
        let crypto = pickerView.tag == 2000 ? depositCrypto : receiveCrypto
        
        if crypto == cryptos[row] {
            _view.select()
        }
        
        return _view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCrypto = cryptos[row]
        onSelect(crypto: selectedCrypto, from: pickerView)
    }
    
    private func onSelect(crypto: CryptoCurrency, from pickerView: UIPickerView) {
        if pickerView.tag == 2000 {
            if depositCrypto != crypto {
//                contentView.depositView.addressContainer.textView.changeText("")
            }
            
            depositCrypto = crypto
        } else {
            if receiveCrypto != crypto {
//                contentView.receiveView.addressContainer.textView.changeText("")
            }
            
            receiveCrypto = crypto
        }
        
        pickerView.reloadAllComponents()
    }
    
    private func onDepositCryptoChange(_ crypto: CryptoCurrency) {
//        if depositCrypto == .monero && receiveCrypto == .bitcoin {
//            contentView.depositView.amountTextField.text = nil
//            if let amount = receiveAmount {
//                updateDepositAmount(amount)
//            }
//        }
        
        contentView.depositeCardView.pickedCurrency.text = crypto.formatted()
        
        
        if store.state.walletState.walletType.currency == crypto {
            contentView.depositeCardView.walletNameLabel.text = store.state.walletState.name
            contentView.depositeCardView.walletNameLabel.isHidden = false
//            contentView.depositeCardView.hideAddressViewField()
//            contentView.depositeCardView.showWalletName()
        } else {
            contentView.depositeCardView.walletNameLabel.isHidden = true
//            contentView.depositView.showAddressViewField()
//            contentView.depositView.hideWalletName()
        }

        updateReceiveResult(with: depositAmount)
        contentView.depositeCardView.flex.markDirty()
        contentView.setNeedsLayout()
        updateLimits()
    }
    
    @objc
    private func onDepositAmountChange(_ textField: UITextField) {
        updateReceiveResult(with: depositAmount)
    }
    
    @objc
    private func onReceiveAmountChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        let amount = makeAmount(from: text.replacingOccurrences(of: ",", with: "."), for: receiveCrypto)
        receiveAmount = amount
        updateReceiveResult(with: amount)
        updateDepositAmount(amount)
    }
    
    private func updateLimits() {
        if depositCrypto == .monero && receiveCrypto == .bitcoin {
            hideAmountTextFieldForDeposit()
            showAmountTextFieldForReceive()
            setProviderTitle()
            fetchXMRTOLimits() { [weak self] result in
                DispatchQueue.main.async {
                    guard let receiveCrypto = self?.receiveCrypto else {
                        return
                    }
                    
                    switch result {
                    case let .success(limits):
                        let min = makeAmount(from: String(limits.min), for: receiveCrypto)
                        let max = makeAmount(from: String(limits.max), for: receiveCrypto)
                        self?.hideLimitsForDeposit()
                        self?.updateReceive(min: min, max: max)
                    case let.failed(error):
                        print(error)
                    }
                }
            }
            return
        }
        
        hideAmountLabelsForDeposit()
        hideAmountTextFieldForReceive()
        showAmountTextFieldForDeposit()
        setProviderTitle()
        
        fetchLimits(for: depositCrypto, and: receiveCrypto) { [weak self] result in
            DispatchQueue.main.async {
                guard let depositCrypto = self?.depositCrypto else {
                    return
                }
                
                switch result {
                case let .success(limits):
                    let min = makeAmount(from: limits.min, for: depositCrypto)
                    let max = makeAmount(from: limits.max, for: depositCrypto)
                    self?.updateDeposit(min: min, max: max)
                case let.failed(error):
                    print(error)
                }
            }
        }
        
        hideLimitsForReceive()
    }
    
    private func onReceiveCryptoChange(_ crypto: CryptoCurrency) {
//        if depositCrypto == .monero && receiveCrypto == .bitcoin {
//            contentView.depositView.amountTextField.text = nil
//            contentView.receiveView.amountTextField.text = nil
//        }
//
//        if store.state.walletState.walletType.currency == receiveCrypto {
//            contentView.receiveView.walletNameLabel.text = store.state.walletState.name
//            contentView.receiveView.walletNameLabel.isHidden = false
//            contentView.receiveView.hideAddressViewField()
//            contentView.receiveView.showWalletName()
//        } else {
//            contentView.receiveView.walletNameLabel.isHidden = true
//            contentView.receiveView.showAddressViewField()
//            contentView.receiveView.hideWalletName()
//        }
//
//        updateReceiveResult(with: depositAmount)
//        contentView.receiveView.flex.markDirty()
        contentView.setNeedsLayout()
        updateLimits()
    }

    private func changedWallet(type: WalletType) {
//        if type.currency == depositCrypto {
//            contentView.depositView.hideAddressViewField()
//        } else {
//            contentView.depositView.showAddressViewField()
//        }
//
//        if type.currency == receiveCrypto {
//            contentView.receiveView.hideAddressViewField()
//        } else {
//            contentView.receiveView.showAddressViewField()
//        }
        
        contentView.setNeedsLayout()
    }
    
    private func updateReceiveResult(with amount: Amount) {
        if
            let crypto = amount.currency as? CryptoCurrency,
            crypto == receiveCrypto {
                contentView.receiveCardView.receiveViewAmount.text = String(format: "%@ %@", amount.formatted(), receiveCrypto.formatted())
                return
        }
        
        let rate = depositCrypto == receiveCrypto
            ? 1
            :self.store.state.exchangeState.rates[depositCrypto]?[receiveCrypto] ?? 0
        let formattedAmount = amount.formatted().replacingOccurrences(of: ",", with: ".")
        let result = rate * (Double(formattedAmount) ?? 0)
        let amount: Amount
        
        switch receiveCrypto {
        case .bitcoin:
            amount = BitcoinAmount(from: String(result))
        case .monero:
            amount = MoneroAmount(from: String(result))
        case .bitcoinCash, .dash, .liteCoin:
            amount = EDAmount(from: String(result), currency: receiveCrypto)
        case .ethereum:
            amount = EthereumAmount(from: String(result))
        }
        
        
        contentView.receiveCardView.receiveViewAmount.text = String(format: "%@ %@", amount.formatted(), receiveCrypto.formatted())
    }
    
    private func updateDeposit(min: Amount, max: Amount) {
        minDepositAmount = min
        maxDepositAmount = max
//        contentView.depositView.minLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("min", comment: ""), min.formatted(), min.currency.formatted())
//        contentView.depositView.maxLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("max", comment: ""), max.formatted(), max.currency.formatted())
//        contentView.depositView.minLabel.flex.markDirty()
//        contentView.depositView.maxLabel.flex.markDirty()
//        contentView.depositView.flex.layout()
//        contentView.depositView.limitsRow.isHidden = false
    }
    
    private func updateDepositAmount(_ amount: Amount) {
//        if contentView.depositView.amountTitleLabel.isHidden {
//            contentView.depositView.amountTitleLabel.isHidden = false
//        }
//
//        if contentView.depositView.amountLabel.isHidden {
//            contentView.depositView.amountLabel.isHidden = false
//        }
        
        let rate = depositCrypto == receiveCrypto
            ? 1
            :self.store.state.exchangeState.rates[receiveCrypto]?[depositCrypto] ?? 0
        let formattedAmount = amount.formatted().replacingOccurrences(of: ",", with: ".")
        let doubleAmount = (Double(formattedAmount) ?? 0)
        let result = rate == 0 ? 0 : doubleAmount * rate
//        contentView.depositView.amountLabel.text = String(format: "%@ %@", String(format: "%.4f", result), depositCrypto.formatted())
//        contentView.depositView.amountLabel.flex.markDirty()
//        contentView.depositView.flex.layout()
    }
    
    private func hideAmountLabelsForDeposit() {
//        contentView.depositView.amountTitleLabel.isHidden = true
//        contentView.depositView.amountLabel.text = nil
//        contentView.depositView.amountLabel.isHidden = true
//        contentView.depositView.amountLabel.flex.markDirty()
//        contentView.depositView.flex.layout()
    }
    
    private func hideLimitsForDeposit() {
//        contentView.depositView.limitsRow.isHidden = true
    }
    
    private func hideLimitsForReceive() {
//        contentView.receiveView.limitsRow.isHidden = true
    }
    
    private func hideAmountTextFieldForDeposit() {
//        contentView.depositView.amountTextField.isHidden = true
//        contentView.depositView.amountTextField.flex.height(0).markDirty()
//        contentView.depositView.flex.layout()
    }
    
    private func hideAmountTextFieldForReceive() {
//        contentView.receiveView.amountTextField.isHidden = true
//        contentView.receiveView.amountTextField.flex.height(0).markDirty()
//        contentView.receiveView.flex.layout()
    }
    
    private func showAmountTextFieldForDeposit() {
//        guard contentView.depositView.amountTextField.isHidden else {
//            return
//        }
//
//        contentView.depositView.amountTextField.isHidden = false
//        contentView.depositView.amountTextField.flex.height(50).markDirty()
//        contentView.depositView.flex.layout()
    }
    
    private func showAmountTextFieldForReceive() {
//        guard contentView.receiveView.amountTextField.isHidden else {
//            return
//        }
//
//        contentView.receiveView.amountTextField.isHidden = false
//        contentView.receiveView.amountTextField.flex.height(50).markDirty()
//        contentView.receiveView.flex.layout()
    }
    
    private func setProviderTitle() {
        var title = "Powered by Morphtoken"
        var icon = "morphtoken_logo"
        
        if receiveCrypto == .bitcoin && depositCrypto == .monero {
            title = "Powered by XMR.to"
            icon = "xmr_to_logo"
        }
        
        guard contentView.exchangeDescriptionLabel.text != title else {
            return
        }
        
        changeProviderTitle(title, icon: UIImage(named: icon))
    }
    
    private func changeProviderTitle(_ title: String, icon: UIImage? = nil) {
        contentView.exchangeDescriptionLabel.text =  title
        contentView.exchangeLogoImage.image = icon
        contentView.exchangeDescriptionLabel.flex.markDirty()
        contentView.descriptionView.flex.layout()
    }
    
    private func updateReceive(min: Amount, max: Amount) {
        minReceiveAmount = min
        maxReceiveAmount = max
//        contentView.receiveView.minLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("min", comment: ""), min.formatted(), min.currency.formatted())
//        contentView.receiveView.maxLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("max", comment: ""), max.formatted(), max.currency.formatted())
//        contentView.receiveView.minLabel.flex.markDirty()
//        contentView.receiveView.maxLabel.flex.markDirty()
//        contentView.receiveView.limitsRow.isHidden = false
    }
    
    @objc
    private func clear() {
//        contentView.receiveView.amountTextField.text = nil
//        contentView.depositView.amountTextField.text = nil
//        contentView.depositView.addressContainer.textView.text = ""
//        contentView.receiveView.addressContainer.textView.text = ""
        updateReceiveResult(with: makeAmount(from: 0, for: receiveCrypto))
        store.dispatch(ExchangeState.Action.changedTrade(nil))
    }
    
    @objc
    private func exhcnage() {
        let isXMRTO = depositCrypto == .monero && receiveCrypto == .bitcoin
        
        let refundAddress = store.state.walletState.walletType.currency == depositCrypto
            ? store.state.walletState.address
            : depositRefund

        let outputAddress = store.state.walletState.walletType.currency == receiveCrypto
            ? store.state.walletState.address
            : receiveAddress
        
        guard !refundAddress.isEmpty else {
            showInfo(message: NSLocalizedString("refund_address_is_empty", comment: ""))
            return
        }

        guard !outputAddress.isEmpty else {
            showInfo(message: NSLocalizedString("receive_address_is_empty", comment: "")) // fixme
            return
        }

//        if isInversed {
//            guard
//                let minReceiveAmount = minReceiveAmount,
//                let maxReceiveAmount = maxReceiveAmount,
//                let receiveAmount = receiveAmount,
//                receiveAmount.value >= minReceiveAmount.value && receiveAmount.value <= maxReceiveAmount.value else {
//                    showInfo(message: NSLocalizedString("incorrect_deposit_amount", comment: ""))
//                    return
//            }
//        } else {
        
//            guard
//                let minDepositAmount = minDepositAmount,
//                let maxDepositAmount = maxDepositAmount,
//                depositAmount.value >= minDepositAmount.value && depositAmount.value <= maxDepositAmount.value else {
//                    showInfo(message: NSLocalizedString("incorrect_deposit_amount", comment: ""))
//                    return
//            }
        
//            if
//                depositCrypto == store.state.walletState.walletType.currency
//                    && store.state.balanceState.balance.value <= depositAmount.value {
//                showInfo(message: NSLocalizedString("incorrect_deposit_amount", comment: ""))
//                return
//            }
//        }
        
        let output = ExchangeOutput(
            address: outputAddress,
            weight: 10000,
            crypto: receiveCrypto)
        let amount = depositAmount
        showSpinner(withTitle: NSLocalizedString("create_exchange", comment: "")) { alert in
            if
                isXMRTO,
                let receiveAmount = self.receiveAmount {
                self.exchangeActionCreators.createTradeXMRTO(withMoneroAmount: receiveAmount, address: self.receiveAddress) { result in
                    alert.dismiss(animated: true) { [weak self] in
                        guard let this = self else {
                            return
                        }
                        
                        switch result {
                        case let .success(uuid):
                            let alert = ExchangeAlertViewController()
                            alert.onDone = {
                                this.store.dispatch(
                                    this.exchangeActionCreators.getOrderStatusForXMRTO(uuid: uuid)
                                ) {
                                    this.exchangeFlow?.change(route: .exchangeResult(amount))
                                }
                            }
                            alert.setTradeID(uuid)
                            self?.present(alert, animated: true)
                        case let .failed(error):
                            this.store.dispatch(ApplicationState.Action.changedError(error))
                            this.showError(error: error)
                        }
                    }
                }
                return
            }

            self.exchangeActionCreators.createTrade(
                from: self.depositCrypto,
                refund: refundAddress,
                outputs: [output]
            ) { result in
                alert.dismiss(animated: true) { [weak self] in
                    switch result {
                    case let .success(trade):
                        let alert = ExchangeAlertViewController()
                        alert.onDone = {
                            self?.store.dispatch(ExchangeState.Action.changedTrade(trade))
                            self?.exchangeFlow?.change(route: .exchangeResult(amount))
                        }
                        alert.setTradeID(trade.id)
                        self?.present(alert, animated: true)
                    case let .failed(error):
                        self?.store.dispatch(ApplicationState.Action.changedError(error))
                        self?.showError(error: error)
                    }
                }
            }
        }
    }
}

extension ExchangeViewController: QRUriUpdateResponsible {
    func getCrypto(for addressView: AddressView) -> CryptoCurrency {
        return addressView.tag == 2000 ? depositCrypto : receiveCrypto
    }
    
    func update(uri: QRUri) {
        // do nothing...
    }
}

class ExchangeContentAlertView: BaseFlexView {
    let messageLabel: UILabel
    let copiedLabel: UILabel
    let copyButton: CopyButton
    
    required init() {
        messageLabel = UILabel(fontSize: 14)
        copiedLabel = UILabel(fontSize: 12)
        copyButton = CopyButton(title: NSLocalizedString("copy_id", comment: ""), fontSize: 14)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        copyButton.backgroundColor = .vividBlue
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .wildDarkBlue
        copiedLabel.textAlignment = .center
        copiedLabel.textColor = .wildDarkBlue
        backgroundColor = .clear
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).backgroundColor(.clear).define { flex in
            flex.addItem(messageLabel).margin(UIEdgeInsets(top: 0, left: 30, bottom: 30, right: 30))
            flex.addItem(copiedLabel).height(10).marginBottom(5)
            flex.addItem(copyButton).height(56).marginBottom(20).width(80%)
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
