import Foundation

public protocol Wallet {
    static var walletType: WalletType { get }
    var name: String { get }
    var balance: Amount { get }
    var unlockedBalance: Amount { get }
    var address: String { get }
    var currentHeight: UInt64 { get }
    var seed: String { get }
    var isConnected: Bool { get }
    var isWatchOnly: Bool { get }
    var keys: WalletKeys { get }
    var config: WalletConfig { get }
    
    var onNewBlock: ((UInt64) -> Void)? { get set }
    var onBalanceChange: ((Wallet) -> Void)? { get set }
    var onConnectionStatusChange: ((ConnectionStatus) -> Void)? { get set }
    
    func send(amount: Amount?, to address: String, withPriority priority: TransactionPriority) throws -> PendingTransaction
    func blockchainHeight() throws -> UInt64 
    func changePassword(newPassword: String) throws
    func save() throws
    func connect(toNode node: NodeDescription) throws
    func close()
    func startUpdate()
    func transactions() -> TransactionHistory
    func rescan(from height: UInt64, node: NodeDescription) throws
}
