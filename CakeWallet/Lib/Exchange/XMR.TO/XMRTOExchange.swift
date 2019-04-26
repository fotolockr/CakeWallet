import Foundation
import CakeWalletLib
import CWMonero
import SwiftyJSON
import Alamofire

final class XMRTOExchange: Exchange {
    static let provider = ExchangeProvider.xmrto
    private static let xmrtoUri = "https://xmr.to/api/v2/xmr2btc"
    private static let cakeUserAgent = "CakeWallet/XMR iOS"
    private static let rateURI = String(format: "%@/order_parameter_query", xmrtoUri)
    private static let createTradeURI = String(format: "%@/order_create/", xmrtoUri)
    
    let name: String
    
    let pairs: [Pair]
    
    init() {
        pairs = [Pair(from: CryptoCurrency.monero, to: CryptoCurrency.bitcoin, reverse: false)]
        name = "xmr.to"
    }
    
    func createTrade(from request: XMRTOTradeRequest, handler: @escaping (CakeWalletLib.Result<XMRTOTrade>) -> Void) {
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
                
                guard response.response?.statusCode == 201 else {
                    if response.response?.statusCode == 400 {
                        handler(.failed(ExchangerError.credentialsFailed(json["error_msg"].stringValue)))
                    } else {
                        handler(.failed(ExchangerError.tradeNotCreated))
                    }
                    
                    return
                }
                
                let uuid = json["uuid"].stringValue
                let trade = XMRTOTrade(id: uuid, from: request.from, to: request.to)
                handler(.success(trade))
            })
        }
    }
    
    func fetchRates(handler: @escaping (CakeWalletLib.Result<Rates>) -> Void) {
        exchangeQueue.async {
            let url =  URLComponents(string: XMRTOExchange.rateURI)!
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
                    let btcprice = json["price"].double else {
                        return
                }
                
                let price = 1 / btcprice
                let rate = [CryptoCurrency.bitcoin: [CryptoCurrency.monero: price]]
                handler(.success(rate))
            })
        }
    }
}
