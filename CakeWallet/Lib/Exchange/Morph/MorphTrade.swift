import Foundation
import CakeWalletLib
import RxSwift

struct MorphTrade: Trade {
    let id: String
    let from: CryptoCurrency
    let to: CryptoCurrency
    let inputAddress: String
    let outputAdress: String
    let amount: Amount
    let min: Amount
    let max: Amount
    let state: ExchangeTradeState
    let extraId: String?
    let provider: ExchangeProvider
    let outputTransaction: String?
    
    func update() -> Observable<Trade> {
        return Observable.create({ o -> Disposable in
            return Disposables.create()
        })
    }
}
