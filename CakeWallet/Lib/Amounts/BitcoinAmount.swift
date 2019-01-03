import CakeWalletLib
import Foundation

public struct BitcoinAmount: Amount {
    public let currency: Currency = CryptoCurrency.bitcoin
    public let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(value: Int) {
        self.value = UInt64(value)
    }
    
    init(from string: String) {
        let doubleValue = Double(string) ?? 0
        let val = doubleValue * 100000000
        let num = NSNumber(value: val)
        self.value = num.uint64Value
    }
    
    public func formatted() -> String {
        let val = Double(value) / Double(100000000)
        let num = NSNumber(value: val)
        return num.stringValue
    }
}
