import Foundation
import CakeWalletLib
import CWMonero
import SwiftyJSON
import Alamofire
import RxSwift

struct ChangeNowTrade: Trade {
    let id: String
    let from: CryptoCurrency
    let to: CryptoCurrency
    let inputAddress: String
    let amount: Amount
    let payoutAddress: String
    let refundAddress: String?
    let state: ExchangeTradeState
    let extraId: String?
    let provider: ExchangeProvider = .changenow
    let outputTransaction: String?
    
    func update() -> Observable<Trade> {
        return Observable.create({ o -> Disposable in
            let url = "\(ChangeNowExchange.uri)transactions/\(self.id)/\(ChangeNowExchange.apiKey)"
            
            Alamofire.request(url).responseData(completionHandler: { response in
                if let error = response.error {
                    o.onError(error)
                    return
                }
                
                guard let data = response.data else {
                    return
                }
                
                do {
                    let json = try JSON(data: data)
                    
                    //                    "id": "b712390255",
                    //                    "status": "finished",
                    //                    "hash": "transactionhash",
                    //                    "payinHash": "58eccbfb713d430004aa438a",
                    //                    "payoutHash": "58eccbfb713d430004aa438a",
                    //                    "payinAddress": "58eccbfb713d430004aa438a",
                    //                    "payoutAddress": "0x9d8032972eED3e1590BeC5e9E4ea3487fF9Cf120",
                    //                    "payinExtraId": "123456",
                    //                    "payoutExtraId": "123456",
                    //                    "fromCurrency": "btc",
                    //                    "toCurrency": "eth",
                    //                    "amountSend": "1.000001",
                    //                    "amountReceive": "20.000001",
                    //                    "networkFee": "0.000001",
                    //                    "updatedAt": "2017-11-29T19:17:55.130Z"
                    let state = ExchangeTradeState(fromChangenow: json["status"].stringValue) ?? self.state
                    let trade = ChangeNowTrade(
                        id: self.id,
                        from: self.from,
                        to: self.to,
                        inputAddress: json["payinAddress"].stringValue,
                        amount: self.amount,
                        payoutAddress: json["payoutAddress"].stringValue,
                        refundAddress: self.refundAddress,
                        state: state,
                        extraId: json["payinExtraId"].string,
                        outputTransaction: json["payoutHash"].string)
                    o.onNext(trade)
                } catch {
                    o.onError(error)
                }
                
            })
            
            return Disposables.create()
        })
    }
}
