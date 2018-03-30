//
//  ExchangeViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 10.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import PromiseKit
import Starscream
import SwiftyJSON
import AVFoundation
import QRCodeReader
import QRCode

// FIX-ME: Refactor me please, someone please... I wanna live in separated files with my friends.

// I'll do it in next release... I promise.

private let morphTokenUri = "https://api.morphtoken.com"

enum CryptoCurrency {
    case monero, bitcoin, ethereum, bitcoinCash, liteCoin, dash
    
    static var all: [CryptoCurrency] {
        return [.monero, .bitcoin, .ethereum, .bitcoinCash, .liteCoin, .dash]
    }
    
    var symbol: String {
        switch self {
        case .monero:
            return "XMR"
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .bitcoinCash:
            return "BCH"
        case .liteCoin:
            return "LTC"
        case .dash:
            return "DASH"
        }
    }
}

protocol Exchanger {
    func createTrade(from input: CryptoCurrency, refund: String, outputs: [ExchangeOutput]) -> Promise<ExchangeTrade>
}

struct ExchangeOutput {
    let address: String
    let weight: Int
    let crypto: CryptoCurrency
}

struct ExchangeTrade {
    let id: String
    let inputCurrency: CryptoCurrency
    let inputAddress: String
    let min: Amount
    let max: Amount
}

enum ExchangerError: Error {
    case credentialsFailed(String)
}

extension ExchangerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .credentialsFailed(reason):
            return reason
        }
    }
}

final class MorphExchanger: Exchanger {
    private static let ref = "cakewallet"
    private var socket: WebSocket
    private var id: String
    var onError: ((Error) -> Void)?
    var onTickerChange: (([String: [String: String]]) -> Void)?
    
    init() {
        let url = URL(string: "wss://api.morphtoken.com/streaming/480/lvtxyayw/websocket")!
        id = ""
        socket = WebSocket(url: url)
    }
    
    func connect() {
        DispatchQueue.global(qos: .background).async {
            self.socket.connect()
            self.config()
        }
    }
    
    func createTrade(from input: CryptoCurrency, refund: String, outputs: [ExchangeOutput]) -> Promise<ExchangeTrade> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .utility).async {
                let url =  URLComponents(string: "\(morphTokenUri)/morph")!
                var request = URLRequest(url: url.url!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let requestBody: [String : Any] = [
                    "input": [
                        "asset": input.symbol,
                        "refund": refund
                    ],
                    "output": outputs.map({[
                        "asset": $0.crypto.symbol,
                        "weight": $0.weight,
                        "address": $0.address
                        ]}),
                    "tag": MorphExchanger.ref
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
                    
                    request.httpBody = jsonData
                } catch {
                    reject(error)
                }
                
                let connection = URLSession.shared.dataTask(with: request) { data, response, error in
                    do {
                        if let error = error {
                            reject(error)
                            return
                        }

                        guard let data = data else {
                            return
                        }
                        
                        let decoded = try JSON(data: data)
                        
                        if decoded["success"].exists() {
                            if  !decoded["success"].boolValue {
                                reject(ExchangerError.credentialsFailed(decoded["description"].stringValue))
                                return
                            }
                        }
                        
                        guard
                            let depositAddress = decoded["input"]["deposit_address"].string,
                            let id = decoded["id"].string,
                            let minAmount = decoded["input"]["limits"]["min"].int,
                            let maxAmount = decoded["input"]["limits"]["max"].int else {
                                return
                        }
                        
                        self.id = id
                        let min: Amount
                        let max: Amount

                        switch input {
                        case .bitcoin:
                            min = BitcoinAmount(value: minAmount)
                            max = BitcoinAmount(value: maxAmount)
                        case .monero:
                            min = MoneroAmount(value: minAmount)
                            max = MoneroAmount(value: maxAmount)
                        case .bitcoinCash, .dash, .liteCoin:
                            min = EDAmount(value: minAmount)
                            max = EDAmount(value: maxAmount)
                        case .ethereum:
                            min = EthereumAmount(value: minAmount)
                            max = EthereumAmount(value: maxAmount)
                        }
                        
                        try self.join(to: id)
                        let trade = ExchangeTrade(id: id, inputCurrency: input, inputAddress: depositAddress, min: min, max: max)
                        fulfill(trade)
                    } catch {
                        reject(error)
                    }
                }
                
                connection.resume()
            }
        }
    }
    
    private func join(to id: String) throws {
        let message = "{\"type\":\"join\",\"channel\":\"\(id)\"}"
        socket.write(string: message)
    }
    
    private func config() {
        socket.onText = { [weak self] text in
            guard text.count > 1 else {
                return
            }
            
            let startIndex = text.index(text.startIndex, offsetBy: 3)
            let endIndex = text.index(text.endIndex, offsetBy: -2)
            let text = text[startIndex..<endIndex].replacingOccurrences(of: "\\", with: "")
            let json = JSON(parseJSON: text)
            let type = json["type"].stringValue
//            print("type \(type)")
//            print("text \(text)")
            
            switch type {
            case "ticker":
                if
                    let data = json["data"].dictionaryObject,
                    let ticker = data as? [String: [String: String]] {
                    self?.onTickerChange?(ticker)
                }
//            case "tx":
//                print("tx")
//                print("json \(json)")
            default:
                break
//                print("default")
//                print("json \(json)")
            }
        }
        
        socket.onDisconnect = { [weak self] error in
            if let error = error {
                self?.onError?(error)
            } else {
                print("Disconnected morphtoken webscoket.")
            }
        }
    }
}

final class ExchangeViewController: BaseViewController<ExchangeView>, UIPickerViewDelegate, UIPickerViewDataSource {    
    private var inputCrypto: CryptoCurrency {
        didSet { onInputCryptoChanged() }
    }
    private var outputCrypto: CryptoCurrency {
        didSet { onOutputCryptoChanged () }
    }
    private var refund: String {
        if inputCrypto == .monero {
            return wallet.address
        } else {
            return contentView.depositView.refundTextField.text ?? ""
        }
    }
    private var inputAmountStr: String {
        return contentView.depositView.amountTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
    }
    private var outputAddress: String {
        return outputCrypto == .monero
            ? wallet.address
            : contentView.receiveView.addressTextField.text ?? ""
    }
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    private let exchanger: MorphExchanger // FIX-ME: dependency on implementation
    private let wallet: WalletProtocol
    private let account: Account
    private let transactionCreation: TransactionCreatableProtocol
    private var inputCryptoOptions: [CryptoCurrency]
    private var outputCryptoOptions: [CryptoCurrency]
    private var rates: [String: [String: String]]
    private var trade: ExchangeTrade? {
        didSet {
            contentView.showDetailsButton.isHidden = trade == nil
        }
    }
    
    init(account: Account, wallet: WalletProtocol, transactionCreation: TransactionCreatableProtocol) {
        self.account = account
        self.wallet = wallet
        self.transactionCreation = transactionCreation
        inputCrypto = .monero
        outputCrypto = .bitcoin
        exchanger = MorphExchanger()
        inputCryptoOptions = CryptoCurrency.all
        outputCryptoOptions = CryptoCurrency.all
        rates = [:]
        super.init()
    }
    
    override func configureDescription() {
        title = "Exchange"
        updateTabBarIcon(name: .exchange)
    }
    
    override func configureBinds() {
        super.configureBinds()
        exchanger.connect()
        exchanger.onError = { error in
            UIAlertController.showError(title: nil, message: error.localizedDescription, presentOn: self)
        }
        
        exchanger.onTickerChange = { [weak self] rates in
            self?.rates = rates
        }

        contentView.exchangeButton.addTarget(self, action: #selector(exchange), for: .touchUpInside)
        contentView.depositView.amountTextField.addTarget(self, action: #selector(onInputAmountChange(_:)), for: .editingChanged)
        contentView.depositView.refundScanQr.addTarget(self, action: #selector(scanInputQrRefundAddress), for: .touchUpInside)
        contentView.receiveView.addressScanQr.addTarget(self, action: #selector(scanOutputQrAddress), for: .touchUpInside)
        contentView.resetButton.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
        contentView.showDetailsButton.addTarget(self, action: #selector(presentExchangeResult), for: .touchUpInside)
        contentView.depositView.pickerView.delegate = self
        contentView.receiveView.pickerView.delegate = self
        contentView.showDetailsButton.isHidden = true
        reset()
        contentView.poweredByLabel.attributedText =  NSAttributedString(
            string: "Powered by morphtoken.com",
            attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = contentView.safeHeight() > 500 ? contentView.safeHeight() : 500
        contentView.scrollView.contentSize = CGSize(width: contentView.frame.width, height: height)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? inputCryptoOptions.count : outputCryptoOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let options = pickerView.tag == 0 ? inputCryptoOptions : outputCryptoOptions
        return options[row].symbol
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            inputCrypto = inputCryptoOptions[row]
        } else {
            outputCrypto = outputCryptoOptions[row]
            contentView.receiveView.amountLabel.text = outputCrypto.symbol
            calculateOutputAmount()
        }
        
        updateTextCrypto()
    }
    
    @objc
    private func resetButtonAction() {
        let alert = UIAlertController(title: "Reset exchange", message: "Are you sure that reset exchage ?", preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.reset()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc
    private func scanOutputQrAddress() {
        scanQr(crypto: outputCrypto) { address in
            self.contentView.receiveView.addressTextField.text = address
        }
    }
    
    @objc
    private func scanInputQrRefundAddress() {
        scanQr(crypto: inputCrypto) { address in
            self.contentView.depositView.refundTextField.text = address
        }
    }
    
    @objc
    private func exchange() {
        guard !refund.isEmpty else {
            UIAlertController.showInfo(message: "Refund address is empty", presentOn: self)
            return
        }
        
        let output = ExchangeOutput(address: outputAddress, weight: 10000, crypto: outputCrypto)
        let _alert = UIAlertController(title: nil, message: "Create a new exchange", preferredStyle: .alert)
        present(_alert, animated: true)
        
        exchanger.createTrade(from: inputCrypto, refund: refund, outputs: [output])
            .then { [weak self] trade -> Void in
                _alert.dismiss(animated: false) {
                    
                    
                    self?.trade = trade
                    self?.presentExchangeResult()
                }
            }.catch { [weak self] error in
                guard let this = self else { return }
                _alert.dismiss(animated: false) {
                    UIAlertController.showError(title: nil, message: error.localizedDescription, presentOn: this)
                }
        }
    }
    
    @objc
    private func onInputAmountChange(_ textField: UITextField) {
        calculateOutputAmount()
    }
    
    @objc
    private func presentExchangeResult() {
        guard let trade = trade else {
            return
        }
        
        let resultViewController = try! container.resolve(arguments: trade, inputAmountStr) as ExchangeResultViewController

        if
            let tabbar = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let nav = tabbar.selectedViewController as? UINavigationController {
            nav.pushViewController(resultViewController, animated: true)
        }
    }
    
    private func scanQr(crypto: CryptoCurrency, completionHandler: @escaping (String) -> Void) {
        readerVC.completionBlock = { [weak self] result in
            if let value = result?.value {
                let address: String
                
                switch crypto {
                case .bitcoin:
                    address = BitcoinQRResult(value: value).address
                case .monero:
                    address = MoneroQRResult(value: value).address
                default:
                    address = DefaultCryptoQRResult(value: value, for: crypto).address
                }
                
                completionHandler(address)
            }
            
            self?.readerVC.stopScanning()
            self?.readerVC.dismiss(animated: true)
        }
        
        readerVC.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(readerVC, animated: true)
    }
    
    private func calculateOutputAmount() {
        guard
            let rateStr = rates[inputCrypto.symbol]?[outputCrypto.symbol],
            let rate = Float(rateStr),
            let inputAmount = Float(inputAmountStr) else {
                contentView.receiveView.amountLabel.text = "\(outputCrypto.symbol) 0.00"
                return
        }
        
        let amount = inputAmount * rate
        let amountStr = String(amount)
        contentView.receiveView.amountLabel.text = "\(outputCrypto.symbol) \(amountStr)"
    }
    
    private func onInputCryptoChanged() {
        if inputCrypto == .monero {
            contentView.depositView.hideRefund()
        } else if contentView.depositView.refundTextField.isHidden {
            contentView.depositView.showRefund()
        }
     
        calculateOutputAmount()
    }
    
    private func onOutputCryptoChanged() {
        if outputCrypto == .monero {
            contentView.receiveView.hideAddress()
        } else if contentView.receiveView.addressTextField.isHidden {
            contentView.receiveView.showAddress()
        }
    }
    
    private func reset() {
        inputCrypto = .monero
        outputCrypto = .bitcoin
        contentView.depositView.pickerView.selectRow(0, inComponent: 0, animated: false)
        contentView.receiveView.pickerView.selectRow(1, inComponent: 0, animated: false)
        updateTextCrypto()
        contentView.receiveView.amountLabel.text = outputCrypto.symbol
        contentView.receiveView.addressTextField.text = nil
        contentView.depositView.amountTextField.text = nil
        contentView.receiveView.amountLabel.text = nil
        contentView.depositView.refundTextField.text = nil
        trade = nil
        calculateOutputAmount()
    }
    
    private func updateTextCrypto() {
        if inputCrypto == .monero {
            contentView.depositView.cryptoTextField.text = "\(inputCrypto.symbol) (\(wallet.name))"
        } else {
            contentView.depositView.cryptoTextField.text = inputCrypto.symbol
        }
        
        if outputCrypto == .monero {
            contentView.receiveView.cryptoTextField.text = "\(outputCrypto.symbol) (\(wallet.name))"
        } else {
            contentView.receiveView.cryptoTextField.text = outputCrypto.symbol
        }
    }
}
