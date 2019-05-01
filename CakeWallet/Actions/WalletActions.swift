import CakeWalletLib
import CakeWalletCore

public enum WalletActions: HandlableAction {
    case load(withName: String, andType: WalletType, handler: () -> Void)
    case loadCurrentWallet
    case create(withName: String, andType: WalletType, handler: (Result<String>) -> Void)
    case restoreFromSeed(withName: String, andSeed: String, restoreHeight: UInt64, type: WalletType, handler: (Result<Void>) -> Void)
    case restoreFromKeys(withName: String, andAddress: String, viewKey: String, spendKey: String, restoreHeight: UInt64, type: WalletType, handler: (Result<Void>) -> Void)
    case connect(NodeDescription)
    case reconnect
    case connectToCurrentNode
    case fetchSeed
    case fetchWalletKeys
    case save
    case commit(transaction: PendingTransaction, handler: (Result<Void>) -> Void)
    case send(amount: Amount?, toAddres: String, paymentID: String, priority: TransactionPriority, handler: (Result<PendingTransaction>) -> Void)
    case rescan(fromHeight: UInt64, handler: () -> Void)
}
