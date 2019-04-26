import Foundation
import CakeWalletLib

protocol AnyExchange {
    static var provider: ExchangeProvider { get }
    static var tradeType: Trade.Type { get }
    static var tradeRequestType: TradeRequest.Type { get }
    
    var pairs: [Pair] { get }
    
    func createTrade(from request: TradeRequest, handler: @escaping (CakeWalletLib.Result<Trade>) -> Void)
    func fetchRates(handler: @escaping (CakeWalletLib.Result<Rates>) -> Void)
}

extension AnyExchange {
    var provider: ExchangeProvider {
        return Self.provider
    }
}
