import Foundation
import CakeWalletLib

extension TransactionDescription {
    public init(moneroTransactionInfo: MoneroTransactionInfoAdapter) {
        self.init(
            id: moneroTransactionInfo.hash(),
            date: Date(timeIntervalSince1970: moneroTransactionInfo.timestamp()),
            totalAmount: MoneroAmount(value: moneroTransactionInfo.amount()),
            fee: MoneroAmount(value: moneroTransactionInfo.fee()),
            direction: moneroTransactionInfo.direction() != 0 ? .outcoming : .incoming,
            priority: .default,
            status: .ok,
            isPending: moneroTransactionInfo.blockHeight() <= 0,
            height: moneroTransactionInfo.blockHeight(),
            paymentId: moneroTransactionInfo.paymentId(),
            accountIndex: moneroTransactionInfo.subaddrAccount()
        )
    }
}
