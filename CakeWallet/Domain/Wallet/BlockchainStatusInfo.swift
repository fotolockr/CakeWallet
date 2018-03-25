//
//  BlockchainStatus.swift
//  Wallet
//
//  Created by Cake Technologies 11/30/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

enum BlockchainStatus {
    case startingSyncing
    case syncing(BlockchainStatusInfo)
    case synced
}

struct BlockchainStatusInfo {
    let height: UInt64
    let blockchainHeight: UInt64
}
