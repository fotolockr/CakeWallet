import CakeWalletLib
import SwiftyJSON
import Alamofire

protocol Exchange: RateFetchable, AnyExchange {
    associatedtype TradeType: Trade
    associatedtype TradeRequestType: TradeRequest
    
    var name: String { get }
    func createTrade(from request: TradeRequestType, handler: @escaping (CakeWalletLib.Result<TradeType>) -> Void)
}

extension Exchange {
    static var tradeType: Trade.Type {
        return TradeType.self
    }
    
    static var tradeRequestType: TradeRequest.Type {
        return TradeRequestType.self
    }
    
    func createTrade(from request: TradeRequest, handler: @escaping (CakeWalletLib.Result<Trade>) -> Void) {
        if
            let request = request as? TradeRequestType,
            let handler = handler as? (CakeWalletLib.Result<TradeType>) -> Void {
            createTrade(from: request, handler: handler)
        } else {
            assertionFailure("Cannot cast trade type. Incorrect trade type.")
        }
    }
}
