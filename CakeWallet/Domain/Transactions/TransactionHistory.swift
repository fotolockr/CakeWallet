//
//  TransactionHistory.swift
//  Wallet
//
//  Created by Cake Technologies 11/13/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

protocol TransactionHistory {
    var count: Int { get }
    var transactions: [TransactionDescription] { get }
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription]
}
