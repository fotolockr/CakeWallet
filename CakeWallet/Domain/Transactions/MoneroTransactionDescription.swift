//
//  MoneroTransaction.swift
//  Wallet
//
//  Created by Cake Technologies 11/26/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

extension TransactionDescription {
    init(moneroTransactionInfo: MoneroTransactionInfoAdapter) {
        id = moneroTransactionInfo.hash()
        date = Date(timeIntervalSince1970: moneroTransactionInfo.timestamp())
        totalAmount = MoneroAmount(value: moneroTransactionInfo.amount())
        fee = MoneroAmount(value: moneroTransactionInfo.fee())
        priority = TransactionPriority(rawValue: moneroTransactionInfo.fee()) ?? .default
        status = .ok
        isPending = moneroTransactionInfo.blockHeight() <= 0
        height = moneroTransactionInfo.blockHeight()
        direction = moneroTransactionInfo.direction() != 0 ? .outgoing : .incoming
        paymentId = moneroTransactionInfo.paymentId()
    }
}
