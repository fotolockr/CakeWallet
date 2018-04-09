//
//  NetworkStatus.swift
//  CakeWallet
//
//  Created by Cake Technologies 27.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation

struct Block {
    let height: UInt64
}

struct NewBlockUpdate {
    let block: Block
    let initialBlock: Block
    let lastBlock: Block
    var blocksRemaining: UInt64 {
        if lastBlock.height < block.height {
            return 0
        }
        
        return lastBlock.height - block.height
    }
    
    func calculateProgress() -> Float {
        guard lastBlock.height > initialBlock.height else {
            return 1
        }
        
        guard block.height >= initialBlock.height else {
            return 1
        }
            
        let total = lastBlock.height - initialBlock.height
        let blockHeight = block.height - initialBlock.height
        let _diff = Float(blockHeight) / Float(total)
        return _diff > 1.00 ? 1.00 : _diff
    }
}

enum NetworkStatus {
    case notConnected
    case failedConnection(Date)
    case failedConnectionNext
    case connecting
    case connected
    case startUpdating
    case updating(NewBlockUpdate)
    case updated
}

