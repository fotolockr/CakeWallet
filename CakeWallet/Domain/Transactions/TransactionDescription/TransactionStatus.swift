//
//  TransactionStatus.swift
//  Wallet
//
//  Created by FotoLockr on 12/1/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

enum TransactionStatus {
    case ok
    case pending
    case error(String)
}

extension TransactionStatus: Equatable {
    static func ==(lhs: TransactionStatus, rhs: TransactionStatus) -> Bool {
        var lhsHash = 0
        var rhsHash = 0
        
        switch lhs {
        case .ok:
            lhsHash = 0
        case .pending:
            lhsHash = 1
        case let .error(error):
            lhsHash = error.hash
        }
        
        switch rhs {
        case .ok:
            rhsHash = 0
        case .pending:
            rhsHash = 1
        case let .error(error):
            rhsHash = error.hash
        }
        
        return lhsHash == rhsHash
    }
}
