import Foundation
import CakeWalletLib

struct XMRTOTradeRequest: TradeRequest {
    let from: Currency
    let to: Currency
    let amount: Amount
    let address: String
    
    init(from: Currency, to: Currency, amount: Amount, address: String) {
        self.from = from
        self.to = to
        self.amount = amount
        self.address = address
    }
}
