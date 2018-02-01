//
//  WalletIndex.swift
//  Wallet
//
//  Created by FotoLockr on 12/3/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

struct WalletIndex {
    let name: String
    let type: WalletType
    
    init(name: String) {
        self.name = name
        type = .monero
    }
}
