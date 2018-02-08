//
//  EmptyTransactionHistory.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation

struct EmptyTransactionHistory: TransactionHistory {
    let count = 0
    let transactions: [TransactionDescription] = []
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription] {
        return []
    }
}
