import Foundation
import CakeWalletLib

struct MorphTradeRequest: TradeRequest {
    let from: Currency
    let to: Currency
    let refundAddress: String
    let weight: Int
    let outputAdress: String
    
    init(from: Currency, to: Currency, refundAddress: String, outputAdress: String, weight: Int = 10000) {
        self.from = from
        self.to = to
        self.refundAddress = refundAddress
        self.outputAdress = outputAdress
        self.weight = weight
    }
}
