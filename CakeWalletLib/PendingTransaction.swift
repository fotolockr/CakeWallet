import Foundation

public struct PendingTransactionDescription: Equatable {
    public static func == (lhs: PendingTransactionDescription, rhs: PendingTransactionDescription) -> Bool {
        return lhs.amount.compare(with: rhs.amount) && lhs.fee.compare(with: rhs.fee) && lhs.status == rhs.status
    }
    public let status: TransactionStatus
    public let amount: Amount
    public let fee: Amount
    
    public init(status: TransactionStatus, amount: Amount, fee: Amount) {
        self.status = status
        self.amount = amount
        self.fee = fee
    }
}

public protocol PendingTransaction {
    var description: PendingTransactionDescription { get }
//    var id: String { get }
    func commit(_ handler: @escaping (Result<Void>) -> Void)
}
