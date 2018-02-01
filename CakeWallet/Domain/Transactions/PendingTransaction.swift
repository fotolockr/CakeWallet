//
//  PendingTransaction.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation
import PromiseKit

protocol PendingTransaction {
    var description: PendingTransactionDescription { get }
    func commit() -> Promise<Void>
}
