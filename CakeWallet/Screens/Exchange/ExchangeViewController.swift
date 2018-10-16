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

struct ExchangeOutput {
    let address: String
    let weight: Int
    let crypto: CryptoCurrency
}

public enum ExchangeTradeState: String, Formatted {
    case pending, confirming, processing, trading, traded, complete
    
    public func formatted() -> String {
        let prefix = "exchange_trade_state_"
        return NSLocalizedString(prefix + self.rawValue, comment: "")
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
    }
    
    public let id: String
    public let inputCurrency: CryptoCurrency
    public let outputCurrency: CryptoCurrency
    public let inputAddress: String
    public let min: Amount
    public let max: Amount
    public let status: ExchangeTradeState
}

enum ExchangerError: Error {
    case credentialsFailed(String)
    case tradeNotFould(String)
    case limitsNotFoud
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
                    
                    let _rates = ticker.reduce([CryptoCurrency : [CryptoCurrency : Double]](), { generalResult, val -> [CryptoCurrency : [CryptoCurrency : Double]] in
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
                    
                    store.dispatch(ExchangeState.Action.changedRate(_rates))
                })
            }
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
                        status: state)
                    
                    handler(ExchangeState.Action.changedTrade(trade))
                })
            }
        }
    }
    
    func createTrade(from input: CryptoCurrency, refund: String, outputs: [ExchangeOutput]) -> Store<ApplicationState>.AsyncActionProducer {
        return { state, store, handler in
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
                    handler(ApplicationState.Action.changedError(error))
                    return
                }
                
                Alamofire.request(request).responseData(completionHandler: { response in
                    if let error = response.error {
                        handler(ApplicationState.Action.changedError(error))
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data) else {
                            return
                    }
                    
                    if json["success"].exists() && !json["success"].boolValue  {
                        handler(
                            ApplicationState.Action.changedError(
                                ExchangerError.credentialsFailed(json["description"].stringValue)
                            )
                        )
                        
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
                        status: ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending
                    )
                    
                    handler(ExchangeState.Action.changedTrade(trade))
                })
            }
        }
    }
}

//class ExchangableCardViewController<_View: ExchangableCardView & BaseView>: BaseViewController<_View>, UIPickerViewDelegate, UIPickerViewDataSource {
//    let cryptos: [CryptoCurrency]
//    var crypto: CryptoCurrency {
//        didSet {
//            onCryptoChange?(crypto)
//        }
//    }
//    var onCryptoChange: ((CryptoCurrency) -> Void)?
//
//    init(initialCrypto: CryptoCurrency) {
//        self.cryptos = CryptoCurrency.all
//        self.crypto = initialCrypto
//        super.init()
//    }
//
//    override func configureBinds() {
//        contentView.exchangePickerView.pickerView.dataSource = self
//        contentView.exchangePickerView.pickerView.delegate = self
//        contentView.exchangePickerView.pickerView.selectRow(cryptos.index(of: crypto) ?? 0, inComponent: 0, animated: false)
//    }
//
//
//}

//
//final class DepositExchangeViewController: ExchangableCardViewController<DepositExchangeCardView> {
//    var amount: Amount {
//        let stringAmount = contentView.amountTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
//
//        switch crypto {
//        case .bitcoin:
//            return BitcoinAmount(from: stringAmount)
//        case .bitcoinCash, .dash, .liteCoin:
//            return EDAmount(from: stringAmount, currency: crypto)
//        case .ethereum:
//            return EthereumAmount(from: stringAmount)
//        case .monero:
//            return MoneroAmount(from: stringAmount)
//        }
//    }
//
//    var refund: String {
//        return contentView.addressContainer.textView.text ?? ""
//    }
//
//    var onAmountChange: ((Amount) -> Void)?
//
//    override func configureBinds() {
//        super.configureBinds()
//        contentView.amountTextField.addTarget(self, action: #selector(onAmountChanged(_:)), for: .editingChanged)
//        contentView.addressContainer.updateResponsible = self
//    }
//
//    @objc
//    private func onAmountChanged(_ textField: UITextField) {
//        onAmountChange?(amount)
//    }
//}
//
//final class ReceiveExchangeViewController: ExchangableCardViewController<ReceiveExchangeCardView> {
//    var address: String {
//        return contentView.addressContainer.textView.text ?? ""
//    }
//
//    override func configureBinds() {
//        super.configureBinds()
//        contentView.addressContainer.updateResponsible = self
//    }
//
//    func updateResult(string: String) {
//        contentView.amountLabel.text = string
//    }
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
        let stringAmount = contentView.depositView.amountTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        return makeAmount(from: stringAmount, for: depositCrypto)
    }
    
    var depositRefund: String {
        return contentView.depositView.addressContainer.textView.text ?? ""
    }
    
    var receiveAddress: String {
        return contentView.receiveView.addressContainer.textView.text ?? ""
    }
    
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
    
    init(store: Store<ApplicationState>, exchangeFlow: ExchangeFlow?) {
        cryptos = CryptoCurrency.all
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
    
    override func configureBinds() {
        contentView.receiveView.addressContainer.textView.delegate = contentView
        contentView.depositView.addressContainer.textView.delegate = contentView
        contentView.depositView.addressContainer.presenter = self
        contentView.receiveView.addressContainer.presenter = self
        
        contentView.depositView.exchangePickerView.pickerView.dataSource = self
        contentView.depositView.exchangePickerView.pickerView.delegate = self
        contentView.depositView.exchangePickerView.pickerView.selectRow(cryptos.index(of: depositCrypto) ?? 0, inComponent: 0, animated: false)
        onDepositCryptoChange(depositCrypto)
        contentView.depositView.amountTextField.addTarget(self, action: #selector(onDepositAmountChange(_:)), for: .editingChanged)
        contentView.depositView.addressContainer.updateResponsible = self
        
        contentView.receiveView.exchangePickerView.pickerView.dataSource = self
        contentView.receiveView.exchangePickerView.pickerView.delegate = self
        contentView.receiveView.exchangePickerView.pickerView.selectRow(cryptos.index(of: receiveCrypto) ?? 0, inComponent: 0, animated: false)
        contentView.receiveView.addressContainer.updateResponsible = self
        onReceiveCryptoChange(receiveCrypto)
        contentView.depositView.setupWallet(name: store.state.walletState.name)
        updateLimits()
        
        if depositCrypto != store.state.walletState.walletType.currency {
            contentView.depositView.hideWalletName()
        }

        contentView.receiveView.setupWallet(name: store.state.walletState.name)

        if receiveCrypto != store.state.walletState.walletType.currency {
            contentView.receiveView.hideWalletName()
        }
        
        contentView.clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        contentView.exchangeButton.addTarget(self, action: #selector(exhcnage), for: .touchUpInside)
        contentView.exchangeDescriptionLabel.text = "Powered by Morphtoken"
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
                contentView.depositView.addressContainer.textView.changeText("")
            }
            
            depositCrypto = crypto
        } else {
            if receiveCrypto != crypto {
                contentView.receiveView.addressContainer.textView.changeText("")
            }
            
            receiveCrypto = crypto
        }
        
        pickerView.reloadAllComponents()
    }
    
    private func onDepositCryptoChange(_ crypto: CryptoCurrency) {
        if store.state.walletState.walletType.currency == crypto {
            contentView.depositView.walletNameLabel.text = store.state.walletState.name
            contentView.depositView.walletNameLabel.isHidden = false
            contentView.depositView.hideAddressViewField()
            contentView.depositView.showWalletName()
        } else {
            contentView.depositView.walletNameLabel.isHidden = true
            contentView.depositView.showAddressViewField()
            contentView.depositView.hideWalletName()
        }
        
        updateReceiveResult(with: depositAmount)
        contentView.depositView.flex.markDirty()
        contentView.setNeedsLayout()
        updateLimits()
    }
    
    @objc
    private func onDepositAmountChange(_ textField: UITextField) {
        updateReceiveResult(with: depositAmount)
    }
    
    private func updateLimits() {
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
    }
    
    private func onReceiveCryptoChange(_ crypto: CryptoCurrency) {
        if store.state.walletState.walletType.currency == receiveCrypto {
            contentView.receiveView.walletNameLabel.text = store.state.walletState.name
            contentView.receiveView.walletNameLabel.isHidden = false
            contentView.receiveView.hideAddressViewField()
            contentView.receiveView.showWalletName()
        } else {
            contentView.receiveView.walletNameLabel.isHidden = true
            contentView.receiveView.showAddressViewField()
            contentView.receiveView.hideWalletName()
        }
        
        updateReceiveResult(with: depositAmount)
        contentView.receiveView.flex.markDirty()
        contentView.setNeedsLayout()
        updateLimits()
    }

    private func changedWallet(type: WalletType) {
        if type.currency == depositCrypto {
            contentView.depositView.hideAddressViewField()
        } else {
            contentView.depositView.showAddressViewField()
        }

        if type.currency == receiveCrypto {
            contentView.receiveView.hideAddressViewField()
        } else {
            contentView.receiveView.showAddressViewField()
        }
        
        contentView.setNeedsLayout()
    }
    
    private func updateReceiveResult(with amount: Amount) {
        let rate = depositCrypto == receiveCrypto
            ? 1
            :self.store.state.exchangeState.rates[depositCrypto]?[receiveCrypto] ?? 0
        let formattedAmount = amount.formatted().replacingOccurrences(of: ",", with: ".")
        let result = rate * (Double(formattedAmount) ?? 0)
        contentView.receiveView.amountLabel.text = String(format: "%@ %@", String(result), receiveCrypto.formatted())
    }
    
    private func updateDeposit(min: Amount, max: Amount) {
        minDepositAmount = min
        maxDepositAmount = max
        contentView.depositView.minLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("min", comment: ""), min.formatted(), min.currency.formatted())
        contentView.depositView.maxLabel.text = String(format: "%@: %@ %@ ", NSLocalizedString("max", comment: ""), max.formatted(), max.currency.formatted())
        contentView.depositView.minLabel.flex.markDirty()
        contentView.depositView.maxLabel.flex.markDirty()
        contentView.depositView.limitsRow.flex.layout()
    }
    
    @objc
    private func clear() {
        contentView.depositView.amountTextField.text = nil
        contentView.depositView.addressContainer.textView.text = ""
        contentView.receiveView.addressContainer.textView.text = ""
        contentView.receiveView.amountLabel.text = nil
        store.dispatch(ExchangeState.Action.changedTrade(nil))
    }
    
    @objc
    private func exhcnage() {
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

        guard
            let minDepositAmount = minDepositAmount,
            let maxDepositAmount = maxDepositAmount,
            depositAmount.value >= minDepositAmount.value && depositAmount.value <= maxDepositAmount.value else {
                showInfo(message: NSLocalizedString("incorrect_deposit_amount", comment: ""))
                return
        }
        
        if
            depositCrypto == store.state.walletState.walletType.currency
                && store.state.balanceState.balance.value <= depositAmount.value {
            showInfo(message: NSLocalizedString("incorrect_deposit_amount", comment: ""))
            return
        }
        
        let output = ExchangeOutput(
            address: outputAddress,
            weight: 10000,
            crypto: receiveCrypto)
        let amount = depositAmount
        showSpinner(withTitle: NSLocalizedString("create_exchange", comment: "")) { alert in
            self.store.dispatch(
                self.exchangeActionCreators.createTrade(
                    from: self.depositCrypto,
                    refund: refundAddress,
                    outputs: [output]
                )
            ) {
                alert.dismiss(animated: true) { [weak self] in
                    self?.exchangeFlow?.change(route: .exchangeResult(amount))
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
