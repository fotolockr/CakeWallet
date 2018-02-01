//
//  EmptyTransactionHistory.swift
//  CakeWallet
//
//  Created by FotoLockr on 31.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation

struct EmptyTransactionHistory: TransactionHistory {
    let count = 0
    let transactions: [TransactionDescription] = []
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription] {
        return []
    }
}
