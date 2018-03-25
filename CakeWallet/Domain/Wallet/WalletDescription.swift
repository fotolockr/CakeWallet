//
//  WalletDescription.swift
//  Wallet
//
//  Created by Cake Technologies 12/3/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

struct WalletDescription {
    let name: String
    let isWatchOnly: Bool
    
    var index: WalletIndex {
        return WalletIndex(name: name)
    }
}

extension WalletDescription: CellItem {
    func setup(cell: WalletUITableViewCell) {
        cell.configure(name: name, isWatchOnly: isWatchOnly)
    }
}
