//
//  MoneroAmount.swift
//  Wallet
//
//  Created by Cake Technologies 11/26/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

struct MoneroAmount: Amount {
    let value: UInt64
    
    init(value: Int) {
        self.init(value: UInt64(value))
    }
    
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

struct BitcoinAmount: Amount {
    let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(value: Int) {
        self.value = UInt64(value)
    }
    
    func formatted() -> String {
        let val = Double(value) / Double(100000000)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = NSNumber(value: val)
        return formatter.string(from: num) ?? "0.0"
    }
}

struct EDAmount: Amount {
    let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(value: Int) {
        self.value = UInt64(value)
    }
    
    func formatted() -> String {
        let val = Double(value) / Double(100000000)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = NSNumber(value: val)
        return formatter.string(from: num) ?? "0.0"
    }
}

struct EthereumAmount: Amount {
    let value: UInt64
    
    init(value: UInt64) {
        self.value = value
    }
    
    init(value: Int) {
        self.value = UInt64(value)
    }
    
    func formatted() -> String {
        let val = Double(value) / Double(1000000000000000000)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let num = NSNumber(value: val)
        return formatter.string(from: num) ?? "0.0"
    }
}
