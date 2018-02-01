//
//  MoneroAmount.swift
//  Wallet
//
//  Created by FotoLockr on 11/26/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

struct MoneroAmount: Amount {
    let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(amount: String) {
        value = MoneroAmountParser.amount(from: amount)
    }
    
    func formatted() -> String {
        let double = Double(MoneroAmountParser.formatValue(value)) ?? 0.0
        return String(double)
    }
}
