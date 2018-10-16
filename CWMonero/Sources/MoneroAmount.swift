import CakeWalletLib

public struct MoneroAmount: Amount {
    public let currency: Currency = CryptoCurrency.monero
    public let value: UInt64
    
    public init(value: UInt64) {
        self.value = value
    }
    
    public init(from string: String) {
        value = MoneroAmountParser.amount(from: string)
    }
    
    public func formatted() -> String {
        let double = Double(MoneroAmountParser.formatValue(value)) ?? 0.0
        return String(double)
    }
}
