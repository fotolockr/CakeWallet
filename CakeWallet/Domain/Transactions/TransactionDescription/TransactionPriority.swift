//
//  TransactionPriority.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

enum TransactionPriority: UInt64, Stringify {
    case slow = 1
    case `default` = 2
    case fast = 3
    case fastest = 4
    
    func stringify() -> String {
        let description: String
        
        switch self {
        case .slow:
            description = "Slow (x0.25)"
        case .default:
            description = "Default (x1)"
        case .fast:
            description = "Fast (x5)"
        case .fastest:
            description = "Fastest (x41.5)"
        }
        
        return description
    }
}
