//
//  TransactionHistory.swift
//  Wallet
//
//  Created by FotoLockr on 11/13/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

protocol TransactionHistory {
    var count: Int { get }
    var transactions: [TransactionDescription] { get }
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription]
}
