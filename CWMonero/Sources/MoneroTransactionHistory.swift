import Foundation
import CakeWalletLib

public final class MoneroTransactionHistory: TransactionHistory {
    public var transactions: [TransactionDescription] {
        return transactionHisory.getAll().map { TransactionDescription(moneroTransactionInfo: $0) }
    }
    public var count: Int {
        return Int(self.transactionHisory.count())
    }
    private(set) var transactionHisory: MoneroWalletHistoryAdapter
    
    public init(moneroWalletHistoryAdapter: MoneroWalletHistoryAdapter) {
        self.transactionHisory = moneroWalletHistoryAdapter
    }
    
    public func refresh() {
        self.transactionHisory.refresh()
    }
    
    public func newTransactions(afterIndex index: Int) -> [TransactionDescription] {
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
