import Foundation
import CakeWalletLib
import CWMonero
import SwiftyJSON
import Alamofire
import RxSwift

func calculate(rate: Double, amount: Double, currency: CryptoCurrency) -> Amount {
    let price = rate * amount
    return makeAmount(price, currency: currency)
}

final class MorphExchange: Exchange {
    private(set) static var pairs: [Pair] = {
        return CryptoCurrency.all.map { i -> [Pair] in
            return CryptoCurrency.all.map { o -> Pair? in
                // XMR -> BTC is only for XMR.to
                
                if i == .bitcoin && o == .monero {
                    return Pair(from: i, to: o, reverse: false)
                }
                
                if i == .monero && o == .bitcoin {
                    return nil
                }
                
                return Pair(from: i, to: o, reverse: true)
                }.compactMap { $0 }
            }.flatMap { $0 }
    }()
    static let provider = ExchangeProvider.morph
    private static let ref = "cakewallet"
    private static let morphTokenUri = "https://api.morphtoken.com"
    private static let rateURI = String(format: "%@/rates", morphTokenUri)
    private static let createTradeURI = String(format: "%@/morph", morphTokenUri)
    
    let name: String
    let pairs: [Pair]
    private var rates: Rates?
    
    init() {
        pairs = [Pair(from: CryptoCurrency.monero, to: CryptoCurrency.bitcoin, reverse: false)]
        name = "Morph"
    }
    
    func createTrade1(from request: MorphTradeRequest) -> Observable<MorphTrade> {
        return Observable.create({ o -> Disposable in
            exchangeQueue.async {
                let url =  URLComponents(string: "\(MorphExchange.morphTokenUri)/morph")!
                var urlRequest = URLRequest(url: url.url!)
                urlRequest.httpMethod = "POST"
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let bodyJSON: JSON = [
                    "input": [
                        "asset": request.from.formatted(),
                        "refund": request.refundAddress
                    ],
                    "output": [[
                        "asset": request.to.formatted(),
                        "weight": request.weight,
                        "address": request.outputAdress
                    ]],
                    "tag": MorphExchange.ref
                ]
                
                print("bodyJSON", bodyJSON)
                
                do {
                    urlRequest.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
                } catch {
                    o.onError(error)
                    return
                }
                
                Alamofire.request(urlRequest).responseData(completionHandler: { response in
                    if let error = response.error {
                        o.onError(error)
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data) else {
                            return
                    }
                    
                    if json["success"].exists() && !json["success"].boolValue {
                        o.onError(ExchangerError.credentialsFailed(json["description"].stringValue))
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
                    
                    switch request.to {
                    case .bitcoin:
                        min = BitcoinAmount(value: minAmount)
                        max = BitcoinAmount(value: maxAmount)
                    case .monero:
                        min = MoneroAmount(value: UInt64(minAmount))
                        max = MoneroAmount(value: UInt64(maxAmount))
                    case .bitcoinCash, .dash, .liteCoin:
                        min = EDAmount(value: minAmount, currency: request.to)
                        max = EDAmount(value: maxAmount, currency: request.to)
                    case .ethereum:
                        min = EthereumAmount(value: minAmount)
                        max = EthereumAmount(value: maxAmount)
                    }
                    
                    let state = ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending
                    let trade = MorphTrade(
                        id: id,
                        from: request.from,
                        to: request.to,
                        inputAddress: depositAddress,
                        outputAdress: request.outputAdress,
                        amount: request.amount,
                        min: min,
                        max: max,
                        state: state,
                        extraId: nil,
                        provider: .morph,
                        outputTransaction: nil)
                    
//                    let trade = ExchangeTrade(
//                        id: id,
//                        inputCurrency: request.to,
//                        outputCurrency: request.to,
//                        inputAddress: depositAddress,
//                        min: min,
//                        max: max,
//                        status: ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending,
//                        provider: .morph
//                    )
                    
                    o.onNext(trade)
                })
            }

                
            return Disposables.create()
        })
    }
    
    func calculateAmount(_ amount: Double, from input: CryptoCurrency, to output: CryptoCurrency) -> Observable<Amount> {
        guard let rate = self.rates?[input]?[output] else {
            return self.fetchRates().map({
                self.rates = $0
                return $0[input]?[output] ?? 0
            }).map({ calculate(rate: $0, amount: amount, currency: output) })
        }
        
        return Observable.create({ o -> Disposable in
            o.onNext(calculate(rate: rate, amount: amount, currency: output))
            return Disposables.create()
        })
    }
    
    func fetchLimist(from input: CryptoCurrency, to output: CryptoCurrency) -> Observable<ExchangeLimits> {
        return fetchLimits(for: input, and: output)
    }
    
    private func fetchRates() -> Observable<Rates> {
        return Observable.create({ o -> Disposable in
            if let rates = self.rates {
                o.onNext(rates)
                return Disposables.create()
            }
            
            exchangeQueue.async {
                let url =  URLComponents(string: MorphExchange.rateURI)!
                var request = URLRequest(url: url.url!)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                Alamofire.request(request).responseData(completionHandler: { response in
                    if let error = response.error {
                        o.onError(error)
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let json = try? JSON(data: data),
                        let ticker = json["data"].dictionaryObject as? [String: [String: String]] else {
                            return
                    }
                    
                    let rates = ticker.reduce([CryptoCurrency : [CryptoCurrency : Double]](), { generalResult, val -> [CryptoCurrency : [CryptoCurrency : Double]] in
                        guard let crypto = CryptoCurrency(from: val.key) else {
                            return generalResult
                        }
                        
                        var tmp = generalResult
                        let values = val.value.reduce([CryptoCurrency : Double](), { (result, val) -> [CryptoCurrency : Double] in
                            guard let key = CryptoCurrency(from: val.key) else {
                                return result
                            }
                            
                            var _result = result
                            let rate = Double(val.value)
                            _result[key] = rate
                            return _result
                        })
                        
                        tmp[crypto] = values
                        return tmp
                    })
                    
                    self.rates = rates
                    o.onNext(rates)
                })
            }
            
            return Disposables.create()
        })
    }
    
    private func fetchLimits(for inputAsset: CryptoCurrency, and outputAsset: CryptoCurrency, outputWeight: Int = 10000) -> Observable<ExchangeLimits> {
        return Observable.create({ o -> Disposable in
            exchangeQueue.async {
                let url =  URLComponents(string: "\(MorphExchange.morphTokenUri)/limits")!
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
                        o.onError(error)
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
                        o.onError(ExchangerError.limitsNotFoud)
                        return
                    }
                    
                    guard
                        let min = json["input"]["limits"]["min"].uInt64,
                        let max = json["input"]["limits"]["max"].uInt64
                        else {
                            o.onError(ExchangerError.limitsNotFoud)
                            return
                            
                    }
                    
                    let minAmount = makeAmount(min, currency: inputAsset)
                    let maxAmount = makeAmount(max, currency: inputAsset)
                    let limits = ExchangeLimits(min: minAmount, max: maxAmount)
                    o.onNext(limits)
                })
            }
            
            return Disposables.create()
        })
    }
}
