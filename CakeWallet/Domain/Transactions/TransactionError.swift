//
//  TransactionError.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

enum TransactionError: Error {
    case insufficientFunds(Amount, Amount, Amount?, Amount)
    case overallBalance(Amount, Amount?)
    
    init?(from originError: NSError, amount: Amount?, balance: Amount) {
        guard originError.code == 1006 else {
            return nil
        }
        
        let isOverall = originError.description.components(separatedBy: "overall").count > 1
        let error: TransactionError
        
        if isOverall {
            error = .overallBalance(balance, amount)
        } else {
            let txAmountSplit = originError.localizedDescription.components(separatedBy: "transaction amount")
            guard txAmountSplit.count > 1 else {
                return nil
            }
            
            let totalAmountStr = txAmountSplit[1].components(separatedBy: "=").first ?? ""
            let totalAmount = MoneroAmount(amount: totalAmountStr)
            let feeStr = txAmountSplit[1].components(separatedBy: "+")[1].components(separatedBy: "(fee)").first ?? ""
            let fee = MoneroAmount(amount: feeStr)
            error = .insufficientFunds(balance, totalAmount, amount, fee)
        }
        
        self = error
    }
}

extension TransactionError: LocalizedError {
    var errorDescription: String? {
        let error: String
        
        switch self { //You sending amount of XXX is more than your balance of XXXXX
        case let .insufficientFunds(balance, totalAmount, amount, fee):
            if let amount = amount {
                error = "Insufficient Funds.\nYour sending amount of \(totalAmount.formatted()) (amount of \(amount.formatted()) + fee of \(fee.formatted()) is more than your balance of \(balance.formatted())."
            } else {
                error = "Insufficient Funds.\nYour sending amount is more than your balance of \(balance.formatted())."
            }
        case let .overallBalance(balance, amount):
            if let amount = amount {
                error = "Insufficient Balance.\nYour sending amount of \(amount.formatted()) is more than your balance of \(balance.formatted())."
            } else {
                error = "Insufficient Balance.\nYour sending amount is more than your balance of \(balance.formatted())."
            }
        }
        
        return error
    }
}
