import Foundation
import CakeWalletLib

protocol Trade {
    var id: String { get }
    var from: Currency { get }
    var to: Currency { get }
}
