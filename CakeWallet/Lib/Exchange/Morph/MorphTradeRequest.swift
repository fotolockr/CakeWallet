import Foundation
import CakeWalletLib

struct MorphTradeRequest: TradeRequest {
    let from: CryptoCurrency
    let to: CryptoCurrency
    let refundAddress: String
    let weight: Int
    let outputAdress: String
    let amount: Amount
    
    init(from: CryptoCurrency, to: CryptoCurrency, refundAddress: String, outputAdress: String, weight: Int = 10000, amount: Amount) {
        self.from = from
        self.to = to
        self.refundAddress = refundAddress
        self.outputAdress = outputAdress
        self.weight = weight
        self.amount = amount
    }
}
