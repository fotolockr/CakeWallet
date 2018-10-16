import CakeWalletLib
import Foundation

public struct EDAmount: Amount {
    public let currency: Currency
    public let value: UInt64
    
    init(value: UInt64, currency: CryptoCurrency) {
        self.currency = currency
        self.value = value
    }
    
    init(value: Int, currency: CryptoCurrency) {
        self.currency = currency
        self.value = UInt64(value)
    }
    
    init(from string: String, currency: CryptoCurrency) {
        let doubleValue = Double(string) ?? 0
        let val = doubleValue * 100000000
        let num = NSNumber(value: val)
        self.value = num.uint64Value
        self.currency = currency
    }
    
    public func formatted() -> String {
        let val = Double(value) / Double(100000000)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = NSNumber(value: val)
        return formatter.string(from: num) ?? "0.0"
    }
}
