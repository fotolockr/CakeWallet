//
//  BitcoinQRResult.swift
//  CakeWallet
//
//  Created by Cake Technologies on 14.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

struct BitcoinQRResult {
    var address: String {
        return self.value.replacingOccurrences(of: "bitcoin:", with: "")
    }
    
    private let value: String
    
    init(value: String) {
        self.value = value
    }
}

struct DefaultCryptoQRResult {
    var address: String {
        return self.value.replacingOccurrences(of: "\(targetDescription):", with: "")
    }
    
    private let target: CryptoCurrency
    private let value: String
    private var targetDescription: String {
        switch target {
        case .bitcoin:
            return "bitcoin"
        case .bitcoinCash:
            return "bitcoincash"
        case .dash:
            return "dash"
        case .ethereum:
            return "ethereum"
        case .liteCoin:
            return "litecoin"
        case .monero:
            return "monero"
        }
    }
    
    init(value: String, for target: CryptoCurrency) {
        self.value = value
        self.target = target
    }
}
