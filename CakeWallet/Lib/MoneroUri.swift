//
//  MoneroUri.swift
//  CakeWallet
//
//  Created by Cake Technologies on 20.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

struct MoneroUri {
    let address: String
    let amount: Amount?
    
    init(address: String, amount: Amount? = nil) {
        self.address = address
        self.amount = amount
    }
    
    func formatted() -> String {
        var result = "monero:\(address)"
        
        if let amount = amount {
            result += "?tx_amount=\(amount.formatted())"
        }
        
        return result
    }
}
