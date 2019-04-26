import Foundation
import CakeWalletLib

protocol TradeRequest {
    var from: Currency { get }
    var to: Currency { get }
}
