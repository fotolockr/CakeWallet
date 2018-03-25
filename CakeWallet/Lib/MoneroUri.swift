//
//  MoneroUri.swift
//  CakeWallet
//
//  Created by Cake Technologies on 20.02.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

struct MoneroUri {
    let address: String
    let paymentId: String?
    let amount: Amount?
    
    init(address: String, paymentId: String? = nil, amount: Amount? = nil) {
        self.address = address
        self.paymentId = paymentId
        self.amount = amount
    }
    
    func formatted() -> String {
        var result = "monero:\(address)"
        
        if paymentId != nil || amount != nil {
            result += "?"
        }
        
        if let paymentId = paymentId {
            result += "tx_payment_id=\(paymentId)"
        }
        
        if let amount = amount {
            if paymentId != nil {
                result += "&"
            }
            
            result += "tx_amount=\(amount.formatted())"
        }
        
        return result
    }
}
