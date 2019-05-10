import Foundation
import CakeWalletLib

extension TransactionDescription {
    public init(moneroTransactionInfo: MoneroTransactionInfoAdapter) {
        var _hash = moneroTransactionInfo.hash()
        let hash = String(_hash ?? "")
        var _amount = moneroTransactionInfo.amount()
        var _fee = moneroTransactionInfo.fee()
        var _direction = moneroTransactionInfo.direction()
        var _blockHeight = moneroTransactionInfo.blockHeight()
        var _paymentId = moneroTransactionInfo.paymentId()
        let paymentId = String(_paymentId ?? "")
        var _subaddrAccount = moneroTransactionInfo.subaddrAccount()
        var _subaddrIndex = moneroTransactionInfo.subaddrIndex()
        let subaddrIndex = _subaddrIndex?.map({ $0.uint32Value }) ?? []
        var _confirmations = moneroTransactionInfo.confirmations()
        let confirmations = _confirmations
        
        self.init(
            id: hash,
            date: Date(timeIntervalSince1970: moneroTransactionInfo.timestamp()),
            totalAmount: MoneroAmount(value: _amount),
            fee: MoneroAmount(value: _fee),
            direction: _direction != 0 ? .outcoming : .incoming,
            priority: .default,
            status: .ok,
            isPending: _blockHeight <= 0,
            height: _blockHeight,
            paymentId: paymentId,
            accountIndex: _subaddrAccount,
            addressIndecies: subaddrIndex,
            confirmations: confirmations)
        
        _hash = nil
        _amount = 0
        _fee = 0
        _direction = 0
        _blockHeight = 0
        _subaddrAccount = 0
        _subaddrIndex = []
        _paymentId = nil
        _confirmations = 0
    }
}
