//
//  TransactionDescription.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

struct TransactionDescription {
    let id: String
    let date: Date
    let totalAmount: Amount
    let fee: Amount
    let direction: TransactionDirection
    let priority: TransactionPriority
    let status: TransactionStatus
    let isPending: Bool
    let height: UInt64
    let paymentId: String
    
    init(
        id: String,
        date: Date,
        totalAmount: Amount,
        fee: Amount,
        direction: TransactionDirection,
        priority: TransactionPriority,
        status: TransactionStatus,
        isPending: Bool,
        height: UInt64,
        paymentId: String) {
        self.id = id
        self.date = date
        self.totalAmount = totalAmount
        self.fee = fee
        self.direction = direction
        self.priority = priority
        self.status = status
        self.isPending = isPending
        self.height = height
        self.paymentId = paymentId
    }
}

extension TransactionDescription: Equatable {
    static func ==(lhs: TransactionDescription, rhs: TransactionDescription) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status && lhs.isPending == rhs.isPending
    }
}

extension TransactionDescription: CellItem {
    func setup(cell: TransactionUITableViewCell) {
        cell.configure(
            direction: direction,
            formattedAmount: totalAmount.formatted(),
            status: status,
            isPending: isPending,
            recipientAddress: "",
            date: date)
    }
}

struct TransactionMiniDescription {
    let date: Date
    let amount: Amount
    let direction: TransactionDirection
    let isPedning: Bool
}
