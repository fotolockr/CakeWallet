//
//  TransactionCell.swift
//  Wallet
//
//  Created by Cake Technologies 16.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

protocol TransactionCell where Self: UIView {
    func configure(
        id: String,
        direction: TransactionDirection,
        formattedAmount: String,
        status: TransactionStatus,
        isPending: Bool,
        recipientAddress: String,
        date: Date,
        formattedFee: String)
}
