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
            id: moneroPendingTransactionAdapter.txid()?.first as? String ?? "",
            status: status,
            amount: MoneroAmount(value: moneroPendingTransactionAdapter.amount()),
            fee: MoneroAmount(value: moneroPendingTransactionAdapter.fee()))
    }
    
    private let moneroPendingTransactionAdapter: MoneroPendingTransactionAdapter
    
    public var id: String? {
        guard
            let nsstring = moneroPendingTransactionAdapter.txid()?.first as? NSString,
            let data = nsstring.data(using: String.Encoding.utf8.rawValue),
            let res = String(data: data, encoding: .utf8) else {
                return nil
        }
       
        return res
    }
    
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
