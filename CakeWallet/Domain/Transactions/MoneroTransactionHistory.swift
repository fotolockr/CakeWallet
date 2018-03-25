//
//  MoneroTransactionHistory.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

final class MoneroTransactionHistory: TransactionHistory {
    var transactions: [TransactionDescription] {
        return transactionHisory.getAll().map { TransactionDescription(moneroTransactionInfo: $0) }
    }
    var count: Int {
        return Int(self.transactionHisory.count())
    }
    private(set) var transactionHisory: MoneroWalletHistoryAdapter
    
    init(moneroWalletHistoryAdapter: MoneroWalletHistoryAdapter) {
        self.transactionHisory = moneroWalletHistoryAdapter
    }
    
    func refresh() {
        self.transactionHisory.refresh()
    }
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription] {
        guard index >=   0 else {
            return []
        }
        
        let endIndex = count - index
        var transactions = [TransactionDescription]()
        
        for i in index..<endIndex {
            transactions.append(TransactionDescription(moneroTransactionInfo: transactionHisory.transaction(Int32(i))))
        }
        
        return transactions
    }
}
