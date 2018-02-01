//
//  WalletDescription.swift
//  Wallet
//
//  Created by FotoLockr on 12/3/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import Foundation

struct WalletDescription {
    let name: String
    
    var index: WalletIndex {
        return WalletIndex(name: name)
    }
}

extension WalletDescription: CellItem {
    func setup(cell: WalletUITableViewCell) {
        cell.configure(name: name)
    }
}
