import Foundation
import CakeWalletLib

protocol TradeRequest {
    var from: CryptoCurrency { get }
    var to: CryptoCurrency { get }
}
