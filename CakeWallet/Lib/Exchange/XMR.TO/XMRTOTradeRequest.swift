import Foundation
import CakeWalletLib

struct XMRTOTradeRequest: TradeRequest {
    let from: CryptoCurrency
    let to: CryptoCurrency
    let amount: Amount
    let address: String
    
    init(amount: Amount, address: String) {
        self.from = .monero
        self.to = .bitcoin
        self.amount = amount
        self.address = address
    }
}
