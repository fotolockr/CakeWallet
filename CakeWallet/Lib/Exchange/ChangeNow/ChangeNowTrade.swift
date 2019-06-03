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
