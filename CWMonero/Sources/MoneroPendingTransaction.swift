import Foundation
import CakeWalletLib

public struct MoneroPendingTransaction: PendingTransaction {
    public var description: PendingTransactionDescription {
        let status: TransactionStatus
        
        switch moneroPendingTransactionAdapter.status() {
        case 0:
            status = .ok
        default:
            status = .error(moneroPendingTransactionAdapter.errorString())
        }
        
        return PendingTransactionDescription(
            status: status,
            amount: MoneroAmount(value: moneroPendingTransactionAdapter.amount()),
            fee: MoneroAmount(value: moneroPendingTransactionAdapter.fee()))
    }
    
    private let moneroPendingTransactionAdapter: MoneroPendingTransactionAdapter
    
    public init(moneroPendingTransactionAdapter: MoneroPendingTransactionAdapter) {
        self.moneroPendingTransactionAdapter = moneroPendingTransactionAdapter
    }
    
    public func commit(_ handler: @escaping (CakeWalletLib.Result<Void>) -> Void) {
        do {
            try self.moneroPendingTransactionAdapter.commit()
            handler(.success(()))
        } catch {
            handler(.failed(error))
        }
        
    }
}
