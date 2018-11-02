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
        guard
            let formattedValue = MoneroAmountParser.formatValue(value),
            let _value = Double(formattedValue),
            _value != 0 else {
              return "0.0"
        }
        
        return String(_value)
    }
}
