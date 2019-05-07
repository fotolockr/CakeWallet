import Foundation
import CakeWalletLib

enum TransactionDetailsRows: Stringify {
    case id, paymentId, date, amount, height, fee, exchangeID, transactionKey, subaddresses
    
    func string() -> String {
        switch self {
        case .id:
            return NSLocalizedString("transaction_id", comment: "")
        case .paymentId:
            return NSLocalizedString("Payment ID", comment: "")
        case .date:
            return NSLocalizedString("date", comment: "")
        case .amount:
            return NSLocalizedString("amount", comment: "")
        case .height:
            return NSLocalizedString("height", comment: "")
        case .fee:
            return  NSLocalizedString("fee", comment: "")
        case .exchangeID:
            return "Exchange ID"
        case .transactionKey:
            return "Transaction key"
        case .subaddresses:
            return "Subaddresses"
        }
    }
}
