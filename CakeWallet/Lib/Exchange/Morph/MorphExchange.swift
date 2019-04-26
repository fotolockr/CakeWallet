import Foundation
import CakeWalletLib
import CWMonero
import SwiftyJSON
import Alamofire

final class MorphExchange: Exchange {
    static let provider = ExchangeProvider.morph
    private static let ref = "cakewallet"
    private static let morphTokenUri = "https://api.morphtoken.com"
    private static let rateURI = String(format: "%@/rates", morphTokenUri)
    private static let createTradeURI = String(format: "%@/morph", morphTokenUri)
    
    let name: String
    let pairs: [Pair]
    
    init() {
        pairs = [
            Pair(from: CryptoCurrency.monero, to: CryptoCurrency.ethereum, reverse: true),
            Pair(from: CryptoCurrency.monero, to: CryptoCurrency.liteCoin, reverse: true),
            Pair(from: CryptoCurrency.monero, to: CryptoCurrency.dash, reverse: true),
            Pair(from: CryptoCurrency.monero, to: CryptoCurrency.monero, reverse: true),
            Pair(from: CryptoCurrency.bitcoin, to: CryptoCurrency.monero, reverse: false)
        ]
        name = "Morph"
    }
    
    func createTrade(from request: MorphTradeRequest, handler: @escaping (CakeWalletLib.Result<MorphTrade>) -> Void) {
        exchangeQueue.async {
            let url =  URLComponents(string: MorphExchange.createTradeURI)!
            var urlRequest = URLRequest(url: url.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let bodyJSON: JSON = [
                "input": [
                    "asset": request.from.formatted(),
                    "refund": request.refundAddress
                ],
                "output": [
                    "asset": request.to.formatted(),
                    "weight": request.weight,
                    "address": request.outputAdress
                ],
                "tag": MorphExchange.ref
            ]
            
            do {
                urlRequest.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
            } catch {
                handler(.failed(error))
                return
            }
            
            Alamofire.request(urlRequest).responseData(completionHandler: { response in
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
                let input = request.from as! CryptoCurrency
                let state = ExchangeTradeState(rawValue: json["state"].stringValue.lowercased()) ?? .pending
                
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
                
                let trade = MorphTrade(
                    id: id,
                    from: request.from,
                    to: request.to,
                    inputAddress: depositAddress,
                    outputAdress: request.outputAdress,
                    min: min,
                    max: max,
                    status: state)
                
                handler(.success(trade))
            })
        }
    }
    
    func fetchRates(handler: @escaping (CakeWalletLib.Result<Rates>) -> Void) {
        exchangeQueue.async {
            let url =  URLComponents(string: MorphExchange.rateURI)!
            var request = URLRequest(url: url.url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            Alamofire.request(request).responseData(completionHandler: { response in
                if let error = response.error {
                    handler(.failed(error))
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
                
                handler(.success(rates))
            })
        }
    }
}
