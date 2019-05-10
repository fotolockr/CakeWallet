import Foundation
import CakeWalletLib

public class MoneroTransactionHistory: TransactionHistory {
    public var transactionsChanged: (([TransactionDescription]) -> Void)?
    public var transactions: [TransactionDescription]
    public var count: Int {
        return Int(self.transactionHisory.count())
    }
    private(set) var transactionHisory: MoneroWalletHistoryAdapter
    private var isRefreshing = false
    
    public init(moneroWalletHistoryAdapter: MoneroWalletHistoryAdapter) {
        self.transactionHisory = moneroWalletHistoryAdapter
        transactions = []
    }
    
    public func refresh() {
        askToUpdate()
    }
    
    public func askToUpdate() {
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        self.transactionHisory.refresh()
        update()
        isRefreshing = false
    }
    
    public func newTransactions(afterIndex index: Int) -> [TransactionDescription] {
        guard index >=   0 else {
            return []
        }
        
        let endIndex = count - index
        var transactions = [TransactionDescription]()
        
        for i in index..<endIndex {
            var transactionInfo = transactionHisory.transaction(Int32(i))
            
            if let transactionInfo = transactionInfo {
                transactions.append(TransactionDescription(moneroTransactionInfo: transactionInfo))
            }
            
            transactionInfo = nil
        }

        return transactions
    }
    
    private func update() {
        guard let transactions = transactionHisory.getAll()?
            .sorted(by: { $0.timestamp() > $1.timestamp() }) else {
            return
        }
        
        if self.transactions.count != transactions.count {
            self.transactions = transactions
                .map { TransactionDescription(moneroTransactionInfo: $0) }
            transactionsChanged?(self.transactions)
            return
        }
        
        var isDirty = false
        
        for (index, transaction) in transactions.enumerated() {
            let _transaction = self.transactions[index]

            if transaction.isPending() != _transaction.isPending || transaction.confirmations() != _transaction.confirmations {
                isDirty = true
                break
            }
        }
        
        if isDirty {
            self.transactions = transactions
                .map { TransactionDescription(moneroTransactionInfo: $0) }
            transactionsChanged?(self.transactions)
        }
    }
}
