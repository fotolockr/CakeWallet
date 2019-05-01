import CakeWalletLib
import SwiftyJSON
import Alamofire
import RxSwift

protocol Exchange: AnyExchange {
    associatedtype TradeType: Trade
    associatedtype TradeRequestType: TradeRequest
    
    var name: String { get }
    func createTrade1(from request: TradeRequestType) -> Observable<TradeType>
}

extension Exchange {
    static var tradeType: Trade.Type {
        return TradeType.self
    }
    
    static var tradeRequestType: TradeRequest.Type {
        return TradeRequestType.self
    }
    
    func createTrade(from request: TradeRequest) -> Observable<Trade> {
        if let request = request as? TradeRequestType {
            return self.createTrade1(from: request).map({ $0 as Trade })
        }
        
        fatalError("Cannot cast trade type. Incorrect trade type.")
    }
}
