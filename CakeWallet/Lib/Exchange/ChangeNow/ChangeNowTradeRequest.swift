import Foundation
import CakeWalletLib

struct ChangeNowTradeRequest: TradeRequest {
    let from: CryptoCurrency
    let to: CryptoCurrency
    let address: String
    let amount: String
    let refundAddress: String
}
