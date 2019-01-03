import Foundation

public protocol Formatted {
    func formatted() -> String
}

public protocol Currency: Formatted {}

public protocol Amount: Formatted {
    var currency: Currency { get }
    var value: UInt64 { get }
}

extension Amount {
    public func compare(with amount: Amount) -> Bool {
        return type(of: amount) == type(of: self) && amount.value == self.value
    }
}

public enum CryptoCurrency: Currency {
    public static var all: [CryptoCurrency] {
        return [.monero, .bitcoin, .ethereum, .liteCoin, .bitcoinCash, .dash]
    }
    
    case monero, bitcoin, ethereum, dash, liteCoin, bitcoinCash
    
    public init?(from string: String) {
        switch string.uppercased() {
        case "XMR":
            self = .monero
        case "BTC":
            self = .bitcoin
        case "ETH":
            self = .ethereum
        case "DASH":
            self = .dash
        case "LTC":
            self = .liteCoin
        case "BCHABC":
            self = .bitcoinCash
        default:
            return nil
        }
    }
    
    public func formatted() -> String {
        switch self {
        case .monero:
            return "XMR"
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .dash:
            return "DASH"
        case .liteCoin:
            return "LTC"
        case .bitcoinCash:
            return "BCHABC"
        }
    }
}

public enum FiatCurrency: Int, Currency {
    public static var all: [FiatCurrency] {
        return [.aud, .bgn, .brl, .cad, .chf, .cny, .czk, .eur, .dkk, .gbp, .hkd, .hrk, .huf, .idr, .ils, .inr, .isk, .jpy, .krw, .mxn, .myr, .nok, .nzd, .php, .pln, .ron, .rub, .sek, .sgd, .thb, .`try`, .usd, .zar, .vef]
    }
    
    case aud, bgn, brl, cad, chf, cny, czk, eur, dkk, gbp, hkd, hrk, huf, idr, ils, inr, isk, jpy, krw, mxn, myr, nok, nzd, php, pln, ron, rub, sek, sgd, thb, `try`, usd, zar, vef
    
    public func formatted() -> String {
        switch self {
        case .aud:
            return "AUD"
        case .bgn:
            return "BGN"
        case .brl:
            return "BRL"
        case .cad:
            return "CAD"
        case .chf:
            return "CHF"
        case .cny:
            return "CNY"
        case .czk:
            return "CZK"
        case .eur:
            return "EUR"
        case .dkk:
            return "DKK"
        case .gbp:
            return "GBP"
        case .hkd:
            return "HKD"
        case .hrk:
            return "HRK"
        case .huf:
            return "HUF"
        case .idr:
            return "IDR"
        case .ils:
            return "ILS"
        case .inr:
            return "INR"
        case .isk:
            return "ISK"
        case .jpy:
            return "JPY"
        case .krw:
            return "KRW"
        case .mxn:
            return "MXN"
        case .myr:
            return "MYR"
        case .nok:
            return "NOK"
        case .nzd:
            return "NZD"
        case .php:
            return "PHP"
        case .pln:
            return "PLN"
        case .ron:
            return "RON"
        case .rub:
            return "RUB"
        case .sek:
            return "SEK"
        case .sgd:
            return "SGB"
        case .thb:
            return "THB"
        case .try:
            return "TRY"
        case .usd:
            return "USD"
        case .zar:
            return "ZAR"
        case .vef:
            return "VEF"
        }
    }
}
