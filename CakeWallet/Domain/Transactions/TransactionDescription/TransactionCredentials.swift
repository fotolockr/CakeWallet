//
//  TransactionCredentials.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation

struct TransactionCredentials {
    let address: String
    let amount: Amount
    let priority: TransactionPriority
    let paymentId: String
}
