import Foundation
import CakeWalletLib

extension Array where Element: Equatable {
    mutating func appendIfNotExist(_ item: Element) {
        if self.index(of: item) == nil {
            self.append(item)
        }
    }
}

extension Array where Element == Pair {
    func getFrom() -> [CryptoCurrency] {
        var result = [CryptoCurrency]()
        
        for pair in self {
            if pair.reverse {
                result.appendIfNotExist(pair.to)
            }
            
            result.appendIfNotExist(pair.from)
        }
        
        return result
    }
    
    func getTo() -> [CryptoCurrency] {
        var result = [CryptoCurrency]()
        
        for pair in self {
            if pair.reverse {
                result.appendIfNotExist(pair.from)
            }
            
            result.appendIfNotExist(pair.to)
        }
        
        return result
    }
}
