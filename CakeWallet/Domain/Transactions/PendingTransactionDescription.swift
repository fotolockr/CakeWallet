//
//  PendingTransactionDescription.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

struct PendingTransactionDescription {
    let status: TransactionStatus
    let amount: Amount
    let fee: Amount
}
