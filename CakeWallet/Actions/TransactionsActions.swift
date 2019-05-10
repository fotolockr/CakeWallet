import CakeWalletLib
import CakeWalletCore

public enum TransactionsActions: HandlableAction {
    case calculateEstimatedFee(withPriority: TransactionPriority)
    case updateTransactions([TransactionDescription], UInt32)
    case updateTransactionHistory(TransactionHistory, UInt32)
//    case forceUpdateTransactions
    case askToUpdate
}
