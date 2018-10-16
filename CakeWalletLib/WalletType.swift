import Foundation

public enum WalletType {
    case monero, bitcoin
    
    public var currency: CryptoCurrency {
        switch self {
        case .monero:
            return .monero
        case .bitcoin:
            return .bitcoin
        }
    }
    
    public func string() -> String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .monero:
            return "Monero"
        }
    }
}
