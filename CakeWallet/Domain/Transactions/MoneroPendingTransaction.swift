//
//  MoneroPendingTransaction.swift
//  Wallet
//
//  Created by Cake Technologies 11/27/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import Foundation
import PromiseKit

struct MoneroPendingTransaction: PendingTransaction {
    var description: PendingTransactionDescription {
        let status: TransactionStatus
        
        switch moneroPendingTransactionAdapter.status() {
        case 0:
            status = .ok
        default:
            status = .error(moneroPendingTransactionAdapter.errorString())
        }
        
        return PendingTransactionDescription(
            status: status,
            amount: MoneroAmount(value: moneroPendingTransactionAdapter.amount()),
            fee: MoneroAmount(value: moneroPendingTransactionAdapter.fee()))
    }
    
    private let moneroPendingTransactionAdapter: MoneroPendingTransactionAdapter
    
    init(moneroPendingTransactionAdapter: MoneroPendingTransactionAdapter) {
        self.moneroPendingTransactionAdapter = moneroPendingTransactionAdapter
    }
    
    func commit() -> Promise<Void> {
        return Promise { fulfill, reject in
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.moneroPendingTransactionAdapter.commit()
                    fulfill(())
                } catch {
                    reject(error)
                }
            }
        }
    }
}
