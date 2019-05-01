import Foundation
import CakeWalletLib

struct Pair {
    let from: CryptoCurrency
    let to: CryptoCurrency
    let reverse: Bool
}

extension Pair: Equatable {
    static func == (lhs: Pair, rhs: Pair) -> Bool {
        let isReverse = lhs.reverse && rhs.reverse
        
        if isReverse {
            return (lhs.from == rhs.from || lhs.from == rhs.to)
                && (lhs.to == rhs.to || lhs.to == rhs.from)
        }
        
        return lhs.from == rhs.from
            && lhs.to == rhs.to
//            && lhs.reverse == rhs.reverse
    }
}
