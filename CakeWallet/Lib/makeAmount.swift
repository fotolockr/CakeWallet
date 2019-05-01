import Foundation
import CakeWalletLib
import CWMonero

func makeAmount(_ amount: Double, currency: CryptoCurrency) -> Amount {
    let outputAmount: Amount
    let amount = String(amount)
    
    switch currency {
    case .bitcoin:
        outputAmount = BitcoinAmount(from: amount)
    case .monero:
        outputAmount = MoneroAmount(from: amount)
    case .bitcoinCash, .dash, .liteCoin:
        outputAmount = EDAmount(from: amount, currency: currency)
    case .ethereum:
        outputAmount = EthereumAmount(from: amount)
    }
    
    return outputAmount
}

func makeAmount(_ amount: String, currency: CryptoCurrency) -> Amount {
    let outputAmount: Amount
    
    switch currency {
    case .bitcoin:
        outputAmount = BitcoinAmount(from: amount)
    case .monero:
        outputAmount = MoneroAmount(from: amount)
    case .bitcoinCash, .dash, .liteCoin:
        outputAmount = EDAmount(from: amount, currency: currency)
    case .ethereum:
        outputAmount = EthereumAmount(from: amount)
    }
    
    return outputAmount
}

func makeAmount(_ value: UInt64, currency: CryptoCurrency) -> Amount {
    switch currency {
    case .bitcoin:
        return BitcoinAmount(value: value)
    case .bitcoinCash, .dash, .liteCoin:
        return EDAmount(value: value, currency: currency)
    case .ethereum:
        return EthereumAmount(value: value)
    case .monero:
        return MoneroAmount(value: value)
    }
}
