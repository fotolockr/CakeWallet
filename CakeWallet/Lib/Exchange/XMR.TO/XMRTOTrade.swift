import Foundation
import CakeWalletLib

struct XMRTOTrade: Trade {
    let id: String
    let from: Currency
    let to: Currency
    
    init(id: String, from: Currency, to: Currency) {
        self.id = id
        self.from = from
        self.to = to
    }
}
