import CakeWalletLib
import Foundation

public struct EthereumAmount: Amount {
    public let currency: Currency = CryptoCurrency.ethereum
    public let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(value: Int) {
        self.value = UInt64(value)
    }
    
    init(from string: String) {
        let doubleValue = Double(string) ?? 0
        let val = doubleValue * 1000000000000000000
        let num = NSNumber(value: val)
        self.value = num.uint64Value
    }
    
    public func formatted() -> String {
        let val = Double(value) / Double(1000000000000000000)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = NSNumber(value: val)
        return formatter.string(from: num) ?? "0.0"
    }
}
