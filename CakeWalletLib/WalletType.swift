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
    
    public init?(from string: String) {
        switch string.lowercased() {
        case "monero":
                self = .monero
        case "bitcoin":
            self = .bitcoin
        default:
            return nil
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
