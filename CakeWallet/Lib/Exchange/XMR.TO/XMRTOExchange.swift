import Foundation
import CakeWalletLib
import CWMonero
import SwiftyJSON
import Alamofire
import RxSwift

private var xmrtouri = ""
private var checkRequest: DataRequest?

final class XMRTOExchange: Exchange {
    static var pairs: [Pair] = [Pair(from: .monero, to: .bitcoin, reverse: false)]
    static let provider = ExchangeProvider.xmrto
    static func asyncUpdateUri(handler: (() -> Void)? = nil) {
        let url = "\(originalUri)/\(rateSufixUri)"
        
        exchangeQueue.async {
            let request: DataRequest
            
            if let checkRequest = checkRequest {
                request = checkRequest
            } else {
                request = Alamofire.request(url)
                checkRequest = request
            }
            
            request.response { res in
                checkRequest = nil
                guard xmrtouri.isEmpty else {
                    handler?()
                    return
                }

                if res.response?.statusCode == 403 {
                    xmrtouri = proxyUri
                } else {
                    xmrtouri = originalUri
                }
                
                handler?()
            }
        }
    }
    
    static var uri: String {
        guard xmrtouri.isEmpty else {
            return xmrtouri
        }
        
        updateUri()
        
        return xmrtouri
    }
    
    private static func updateUri() {
        guard xmrtouri.isEmpty else {
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        asyncUpdateUri {
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    private static let originalUri = "https://xmr.to/api/v2/xmr2btc"
    private static let proxyUri = "https://xmrproxy.net/api/v2/xmr2btc"
    private static let cakeUserAgent = "CakeWallet/XMR iOS"
    private static let rateSufixUri = "order_parameter_query"
    private static var rateURI: String {
        return String(format: "%@/%@", uri, rateSufixUri)
    }
    private static var createTradeURI: String {
        return String(format: "%@/order_create/", uri)
    }
    
    let name: String
    let pairs: [Pair]
    private var rates: Rates?
    
    init() {
        pairs = [Pair(from: CryptoCurrency.monero, to: CryptoCurrency.bitcoin, reverse: false)]
        name = "xmr.to"
    }
    
    func createTrade1(from request: XMRTOTradeRequest) -> Observable<XMRTOTrade> {
        return Observable.create({ o -> Disposable in
            exchangeQueue.async {
                let url =  URLComponents(string: XMRTOExchange.createTradeURI)!
                var urlRequest = URLRequest(url: url.url!)
                urlRequest.httpMethod = "POST"
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.addValue(XMRTOExchange.cakeUserAgent, forHTTPHeaderField: "User-Agent")
                let bodyJSON: JSON = [
                    "btc_amount": request.amount.formatted().replacingOccurrences(of: ",", with: "."),
                    "btc_dest_address": request.address
                ]
                
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
                    
                    guard response.response?.statusCode == 201 else {
                        if response.response?.statusCode == 400 {
                            o.onError(ExchangerError.credentialsFailed(json["error_msg"].stringValue))
                        } else {
                            o.onError(ExchangerError.tradeNotCreated)
                        }
                        
                        return
                    }
                    
                    let uuid = json["uuid"].stringValue
                    let trade = XMRTOTrade(id: uuid, from: request.from, to: request.to, state: .toBeCreated, inputAddress: "", amount: request.amount)
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
        return Observable.create({ o -> Disposable in
            exchangeQueue.async {
                guard input == .bitcoin && output == .monero else {
                    o.onNext((min: nil, max: nil))
                    return
                }
                
                let url =  URLComponents(string: "\(XMRTOExchange.uri)/order_parameter_query")!
                var request = URLRequest(url: url.url!)
                request.httpMethod = "GET"
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
                    
                    guard
                        let min = json["lower_limit"].double,
                        let max = json["upper_limit"].double
                        else {
                            o.onError(ExchangerError.limitsNotFoud)
                            return
                    }
                    
                    let minAmount = makeAmount(min, currency: input)
                    let maxAmount = makeAmount(max, currency: input)
                    let limits = ExchangeLimits(min: minAmount, max: maxAmount)
                    o.onNext(limits)
                })
            }
            
            return Disposables.create()
        })
    }
    
//    func createTrade(from request: XMRTOTradeRequest, handler: @escaping (CakeWalletLib.Result<XMRTOTrade>) -> Void) {
//        exchangeQueue.async {
//            let url =  URLComponents(string: XMRTOExchange.createTradeURI)!
//            var urlRequest = URLRequest(url: url.url!)
//            urlRequest.httpMethod = "POST"
//            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            urlRequest.addValue(XMRTOExchange.cakeUserAgent, forHTTPHeaderField: "User-Agent")
//            let bodyJSON: JSON = [
//                "btc_amount": request.amount.formatted().replacingOccurrences(of: ",", with: "."),
//                "btc_dest_address": request.address
//            ]
//
//            do {
//                urlRequest.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
//            } catch {
//                handler(.failed(error))
//                return
//            }
//
//            Alamofire.request(urlRequest).responseData(completionHandler: { response in
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
//                let trade = XMRTOTrade(id: uuid, from: request.from, to: request.to)
//                handler(.success(trade))
//            })
//        }
//    }
    
    func fetchRates() -> Observable<Rates> {
        return Observable.create({ o -> Disposable in
            if let rates = self.rates {
                o.onNext(rates)
                return Disposables.create()
            }
            
            exchangeQueue.async {
                let url =  URLComponents(string: XMRTOExchange.rateURI)!
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
                        let btcprice = json["price"].double else {
                            return
                    }
                    
                    let price = 1 / btcprice
                    let rate = [CryptoCurrency.bitcoin: [CryptoCurrency.monero: price]]
                    o.onNext(rate)
                })
            }
        
            return Disposables.create()
        })
    }
}
