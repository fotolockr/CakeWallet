import CakeWalletLib
import CakeWalletCore

public struct CalculateEstimatedFeeHandler: AsyncHandler {
    public func handle(action: TransactionsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .calculateEstimatedFee(priority) = action else { return }
        
        workQueue.async {
            let type = store.state.walletState.walletType
            let gateway = getGateway(for: type)
            gateway.calculateEstimatedFee(forPriority: priority, handler: { result in
                switch result {
                case let .success(fee):
                    handler(TransactionsState.Action.changedEstimatedFee(fee))
                case let .failed(error):
                    handler(ApplicationState.Action.changedError(error))
                }
            })
        }
    }
}

public struct UpdateTransactionsHandler: Handler {
    public func handle(action: TransactionsActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case let .updateTransactions(transactions) = action else { return nil }
        return TransactionsState.Action.reset(transactions)
    }
}

public struct UpdateTransactionHistoryHandler: AsyncHandler {
    public func handle(action: TransactionsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .updateTransactionHistory(transactionHistory) = action else { return }
        
        workQueue.async {
            let transactions = store.state.transactionsState.transactions
            transactionHistory.refresh()
            let refreshedTransactions = transactionHistory.transactions.filter { $0.accountIndex == store.state.walletState.accountIndex }
            
            if
                transactions.count != refreshedTransactions.count || transactions.filter({ $0.isPending }).count > 0 {
                let transactions = refreshedTransactions.sorted(by: { $0.date > $1.date })
                handler(TransactionsState.Action.reset(transactions))
            }
        }
    }
}

public struct ForceUpdateTransactionsHandler: AsyncHandler {
    public func handle(action: TransactionsActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .forceUpdateTransactions = action else { return }
        
        workQueue.async {
            let transactionHistory = currentWallet.transactions()
            transactionHistory.refresh()
            let transactions = transactionHistory.transactions
            handler(TransactionsState.Action.reset(transactions))
        }
    }
}
