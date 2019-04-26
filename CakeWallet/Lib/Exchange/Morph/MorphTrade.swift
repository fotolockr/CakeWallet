import Foundation
import CakeWalletLib

struct MorphTrade: Trade {
    let id: String
    let from: Currency
    let to: Currency
    let inputAddress: String
    let outputAdress: String
    let min: Amount
    let max: Amount
    let status: ExchangeTradeState
    
    init(id: String, from: Currency, to: Currency, inputAddress: String, outputAdress: String, min: Amount, max: Amount, status: ExchangeTradeState) {
        self.id = id
        self.from = from
        self.to = to
        self.inputAddress = inputAddress
        self.outputAdress = outputAdress
        self.min = min
        self.max = max
        self.status = status
    }
}
