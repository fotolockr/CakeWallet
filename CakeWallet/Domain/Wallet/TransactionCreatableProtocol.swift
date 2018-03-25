//
//  TransactionCreatableProtocol.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

protocol TransactionCreatableProtocol {
    func createTransaction(to address: String, withPaymentId paymentId: String,
                           amount: Amount?, priority: TransactionPriority) -> Promise<PendingTransaction>
}
