//
//  MoneroQRResult.swift
//  CakeWallet
//
//  Created by Cake Technologies on 08.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

struct MoneroQRResult {
    var address: String {
        return self.value.slice(from: "monero:", to: "?") ?? self.value
    }
    var amount: Amount? {
        guard let amountStr = self.value.slice(from: "tx_amount=", to: "&") else {
            return nil
        }
        
        return MoneroAmount(amount: amountStr)
    }
    var paymentId: String? {
        return self.value.slice(from: "tx_payment_id=", to: "&")
    }
    private let value: String
    
    init(value: String) {
        self.value = value
    }
}
