public struct FiatAmount: Amount {
    public var currency: Currency
    public let value: UInt64
    public let stringValue: String?
    
    public init(from string: String, currency: FiatCurrency) {
        self.stringValue = string
        self.currency = currency
        self.value = 0
    }
    
    public func formatted() -> String {
        if
            let stringValue = self.stringValue,
            let value = Float(stringValue) {
            let min = 0.01 as Float
            
            if value < min && value != 0 {
                return String(format: "< %.2f %@", min, currency.formatted())
            }
            
            return String(format: "%.2f %@", value, currency.formatted())
        } else {
            return "" //fixme
        }
    }
}
