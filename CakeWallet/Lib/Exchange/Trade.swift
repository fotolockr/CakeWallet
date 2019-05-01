import Foundation
import CakeWalletLib
import RxSwift

protocol Trade {
    var id: String { get }
    var from: CryptoCurrency { get }
    var to: CryptoCurrency { get }
    var amount: Amount { get }
    var inputAddress: String { get }
    var state: ExchangeTradeState { get }
    var extraId: String? { get }
    var provider: ExchangeProvider { get }
    var outputTransaction: String? { get }
    
    func update() -> Observable<Trade>
}
