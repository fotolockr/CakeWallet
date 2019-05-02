import Foundation
import CakeWalletLib
import RxSwift
import SwiftyJSON
import Alamofire
import CWMonero

struct XMRTOTrade: Trade {
    let id: String
    let from: CryptoCurrency
    let to: CryptoCurrency
    let state: ExchangeTradeState
    let amount: Amount
    let inputAddress: String
    let extraId: String?
    let provider: ExchangeProvider = .xmrto
    let expiredAt: Date?
    let outputTransaction: String?
    
    init(id: String, from: CryptoCurrency, to: CryptoCurrency, state: ExchangeTradeState, inputAddress: String, amount: Amount, extraId: String? = nil, expiredAt: Date? = nil, outputTransaction: String? = nil) {
        self.id = id
        self.from = from
        self.to = to
        self.inputAddress = inputAddress
        self.amount = amount
        self.state = state
        self.extraId = extraId
        self.expiredAt = expiredAt
        self.outputTransaction = outputTransaction
    }
    
    func update() -> Observable<Trade> {
        return Observable.create({ o -> Disposable in
            let url = URLComponents(string: String(format: "%@/order_status_query/", XMRTOExchange.uri))!
            var request = URLRequest(url: url.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("CakeWallet/XMR iOS", forHTTPHeaderField: "User-Agent")
            let bodyJSON: JSON = [
                "uuid": self.id
            ]
            
            do {
                request.httpBody = try bodyJSON.rawData(options: .prettyPrinted)
            } catch {
                o.onError(error)
            }
            
            Alamofire.request(request).responseData(completionHandler: { response in
                if let error = response.error {
                    o.onError(error)
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
                let expiredAt = dateFormatter.date(from: json["expires_at"].stringValue)
                let outputTransaction = json["btc_transaction_id"].string
                
                let trade = XMRTOTrade(
                    id: self.id,
                    from: self.from,
                    to: self.to,
                    state: state,
                    inputAddress: address,
                    amount: amount,
                    extraId: paymentId,
                    expiredAt: expiredAt,
                    outputTransaction: outputTransaction)
                
                o.onNext(trade)
            })
            
            return Disposables.create()
        })
    }
}
