//
//  TransactionCreatableProtocol.swift
//  CakeWallet
//
//  Created by FotoLockr on 27.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol TransactionCreatableProtocol {
    func createTransaction(to address: String, withPaymentId paymentId: String,
                           amount: Amount, priority: TransactionPriority) -> Promise<PendingTransaction>
}
