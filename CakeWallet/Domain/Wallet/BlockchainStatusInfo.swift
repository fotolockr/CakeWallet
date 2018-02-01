//
//  BlockchainStatus.swift
//  Wallet
//
//  Created by FotoLockr on 11/30/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
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
