//
//  PendingTransactionDescription.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

struct PendingTransactionDescription {
    let status: TransactionStatus
    let amount: Amount
    let fee: Amount
}
