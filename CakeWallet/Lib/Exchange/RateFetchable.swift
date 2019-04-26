import Foundation
import CakeWalletLib

protocol RateFetchable {
    func fetchRates(handler: @escaping (CakeWalletLib.Result<Rates>) -> Void)
}
