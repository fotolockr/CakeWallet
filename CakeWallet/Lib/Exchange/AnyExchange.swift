import Foundation
import CakeWalletLib
import RxSwift

protocol AnyExchange {
    static var provider: ExchangeProvider { get }
    static var tradeType: Trade.Type { get }
    static var tradeRequestType: TradeRequest.Type { get }
    static var pairs: [Pair] { get }
    
    var pairs: [Pair] { get }
    
    func createTrade(from request: TradeRequest) -> Observable<Trade>
    func calculateAmount(_ amount: Double, from input: CryptoCurrency, to output: CryptoCurrency) -> Observable<Amount>
    func fetchLimist(from input: CryptoCurrency, to output: CryptoCurrency) -> Observable<ExchangeLimits>
}

extension AnyExchange {
    var provider: ExchangeProvider {
        return Self.provider
    }
}
